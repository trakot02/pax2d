package graphics

import "core:log"

//
// Values
//

QUAD_VERTEX_SHADER ::
`
#version 330 core

/*
layout (std140, binding = 0) uniform View {
    mat4 u_view;
}
*/

layout (location = 0) in vec2  a_vertex_coords;
layout (location = 1) in vec4  a_vertex_color;
layout (location = 2) in ivec2 a_texture_coords;
layout (location = 3) in int   a_sampler_index;

out vec4  v_vertex_color;
out ivec2 v_texture_coords;
out int   v_sampler_index;

void main()
{
    v_vertex_color   = a_vertex_color;
    v_texture_coords = a_texture_coords;
    v_sampler_index  = a_sampler_index;

    gl_Position = /* u_view * */ vec4(a_vertex_coords, 0, 1);
}
`

QUAD_PIXEL_SHADER ::
`
#version 330 core

#define TEXTURE_SLOT_MAX 8

// uniform sampler2D u_samplers[TEXTURE_SLOT_MAX];

in vec4  v_vertex_color;
in ivec2 v_texture_coords;
in int   v_sampler_index;

out vec4 p_pixel_color;

void main()
{
    vec4 texture_value = vec4(1);

    // texture_value = texelFetch(u_samplers[v_sampler_index], v_texture_coords);

/*
    switch ( v_sampler_index ) {
        case 0: { texture_value = texelFetch(u_samplers[0], v_texture_coords); } break;
        case 1: { texture_value = texelFetch(u_samplers[1], v_texture_coords); } break;
        case 2: { texture_value = texelFetch(u_samplers[2], v_texture_coords); } break;
        case 3: { texture_value = texelFetch(u_samplers[3], v_texture_coords); } break;
        case 4: { texture_value = texelFetch(u_samplers[4], v_texture_coords); } break;
        case 5: { texture_value = texelFetch(u_samplers[5], v_texture_coords); } break;
        case 6: { texture_value = texelFetch(u_samplers[6], v_texture_coords); } break;
        case 7: { texture_value = texelFetch(u_samplers[7], v_texture_coords); } break;

        default: break;
    }
*/

    p_pixel_color = texture_value * v_vertex_color;
}
`

QUAD_VERTEX_COUNT :: 4
QUAD_INDEX_COUNT  :: 6

//
// Types
//

Quad_Vertex :: struct
{
    vertex_coords:  [2]f32,
    vertex_color:   [4]f32,
    texture_coords: [2]i32,
    sampler_index:  i32,
}

Quad_Index :: u32

Quad_Batch :: struct
{
    mesh:   Mesh,
    shader: Shader,

    vertices: [dynamic]Quad_Vertex,
    indices:  [dynamic]Quad_Index,
}

//
// Procs
//

quad_batch_make :: proc(allocator := context.allocator) -> (Quad_Batch, bool)
{
    value  := Quad_Batch {}
    layout := vertex_layout_make_quad()
    state  := true

    value.mesh, state = mesh_make(Quad_Vertex, Quad_Index, 8192)

    if state == true {
        value.shader, state = shader_make_quad()
    }

    value.vertices = make([dynamic]Quad_Vertex, allocator)
    value.indices  = make([dynamic]Quad_Index, allocator)

    if state == false {
        value.vertices = {}
        value.indices  = {}

        shader_destroy(&value.shader)

        mesh_destroy(&value.mesh)
    }

    mesh_apply_layout(&value.mesh, &layout)

    return value, state
}

quad_batch_destroy :: proc(self: ^Quad_Batch)
{
    delete(self.indices)
    delete(self.vertices)

    shader_destroy(&self.shader)

    mesh_destroy(&self.mesh)

    self.vertices = {}
    self.indices  = {}
}

quad_batch_clear :: proc(self: ^Quad_Batch)
{
    clear(&self.vertices)
    clear(&self.indices)
}

quad_batch_write :: proc(self: ^Quad_Batch)
{
    log.debugf("%v", mesh_write_vertices(&self.mesh, self.vertices[:]))
    log.debugf("%v", mesh_write_indices(&self.mesh, self.indices[:]))

    shader_execute(&self.shader, &self.mesh)
}

quad_batch_add :: proc(self: ^Quad_Batch, vertices: [QUAD_VERTEX_COUNT]Quad_Vertex) -> bool
{
    indices := [QUAD_INDEX_COUNT]Quad_Index {0, 1, 2, 2, 1, 3}

    state := quad_batch_add_vertices(self, vertices)

    if state == false { return state }

    state = quad_batch_add_indices(self, indices)

    if state == false {
        resize(&self.vertices, len(self.vertices) - len(vertices))
    }

    return state
}

@(private)
shader_make_quad :: proc() -> (Shader, bool)
{
    builder := Shader_Builder {}

    shader_builder_add_stage(&builder, .STAGE_VERTEX, QUAD_VERTEX_SHADER)
    shader_builder_add_stage(&builder, .STAGE_PIXEL,  QUAD_PIXEL_SHADER)

    value, state := shader_make_from_builder(&builder)

    if state == false {
        log.debugf("Graphics: Unable to create quad shader")
    }

    shader_builder_clear(&builder)

    return value, state
}

@(private)
vertex_layout_make_quad :: proc() -> Vertex_Layout
{
    layout := Vertex_Layout {}

    vertex_layout_add(&layout, {.TYPE_F32_VEC2}) // vertex_coords
    vertex_layout_add(&layout, {.TYPE_F32_VEC4}) // vertex_color
    vertex_layout_add(&layout, {.TYPE_I32_VEC2}) // texture_coords
    vertex_layout_add(&layout, {.TYPE_I32})      // sampler_index

    return layout
}

@(private)
quad_batch_add_vertices :: proc(self: ^Quad_Batch, vertices: [QUAD_VERTEX_COUNT]Quad_Vertex) -> bool
{
    first := len(self.vertices)
    items := len(vertices)

    error := resize(&self.vertices, first + items)

    if error == nil {
        for item in 0 ..< items {
            assign_at(&self.vertices, first + item, vertices[item])
        }

        return true
    }

    log.errorf("Quad_Batch: Unable to add vertices")

    return false
}

@(private)
quad_batch_add_indices :: proc(self: ^Quad_Batch, indices: [QUAD_INDEX_COUNT]Quad_Index) -> bool
{
    first := len(self.indices)
    items := len(indices)

    error := resize(&self.vertices, first + items)

    if error == nil {
        for item in 0 ..< items {
            assign_at(&self.indices, first + item, indices[item])
        }

        return true
    }

    log.errorf("Quad_Batch: Unable to add indices")

    return false
}
