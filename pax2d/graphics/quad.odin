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
layout (location = 2) in vec2  a_texture_coords;
layout (location = 3) in float a_texture_index;

out vec4  v_vertex_color;
out vec2  v_texture_coords;
out float v_texture_index;

void main()
{
    v_vertex_color   = a_vertex_color;
    v_texture_coords = a_texture_coords;
    v_texture_index  = a_texture_index;

    gl_Position = /* u_view * */ vec4(a_vertex_coords, 0, 1);
}
`

QUAD_PIXEL_SHADER ::
`
#version 330 core

#define TEXTURE_SLOT_MAX 8

uniform sampler2D u_textures[TEXTURE_SLOT_MAX];

in vec4  v_vertex_color;
in vec2  v_texture_coords;
in float v_texture_index;

out vec4 p_pixel_color;

void main()
{
    vec2 texture_coords = v_texture_coords;
    int  texture_index  = int(v_texture_index);

    p_pixel_color = v_vertex_color;

    switch ( texture_index ) {
        case 0: { p_pixel_color *= texture(u_textures[0], texture_coords, 0); } break;
        case 1: { p_pixel_color *= texture(u_textures[1], texture_coords, 0); } break;
        case 2: { p_pixel_color *= texture(u_textures[2], texture_coords, 0); } break;
        case 3: { p_pixel_color *= texture(u_textures[3], texture_coords, 0); } break;
        case 4: { p_pixel_color *= texture(u_textures[4], texture_coords, 0); } break;
        case 5: { p_pixel_color *= texture(u_textures[5], texture_coords, 0); } break;
        case 6: { p_pixel_color *= texture(u_textures[6], texture_coords, 0); } break;
        case 7: { p_pixel_color *= texture(u_textures[7], texture_coords, 0); } break;

        default: break;
    }
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
    texture_coords: [2]f32,
    texture_index:  f32,
}

Quad_Index :: u32

Quad_Batch :: struct
{
    geometry: Geometry_Batch,
    textures: Texture_Table,
    shader:   Shader,

    vertices: [dynamic]Quad_Vertex,
    indices:  [dynamic]Quad_Index,
}

//
// Procs
//

quad_batch_make :: proc(limit: int, allocator := context.allocator) -> (Quad_Batch, bool)
{
    value := Quad_Batch {}
    state := true

    value.geometry, state = geometry_batch_alloc(limit, Quad_Vertex, Quad_Index)

    if state == true {
        layout := vertex_layout_make_quad()

        geometry_batch_apply_layout(&value.geometry, &layout)

        value.shader, state = shader_make_quad()
    }

    value.vertices = make([dynamic]Quad_Vertex, allocator)
    value.indices  = make([dynamic]Quad_Index, allocator)

    if state == false {
        value.vertices = {}
        value.indices  = {}

        shader_destroy(&value.shader)

        geometry_batch_destroy(&value.geometry)
    }

    return value, state
}

quad_batch_destroy :: proc(self: ^Quad_Batch)
{
    delete(self.indices)
    delete(self.vertices)

    shader_destroy(&self.shader)

    geometry_batch_destroy(&self.geometry)

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
    geometry_batch_write_to_front(&self.geometry,
        self.vertices[:], self.indices[:])

    shader_execute(&self.shader, &self.geometry,
        &self.textures)
}

quad_batch_add :: proc(self: ^Quad_Batch, vertices: [QUAD_VERTEX_COUNT]Quad_Vertex, texture: Texture_Slot) -> bool
{
    indices := [QUAD_INDEX_COUNT]Quad_Index {0, 1, 2, 2, 1, 3}

    state := quad_batch_add_vertices(self, vertices)

    if state == false { return state }

    state = quad_batch_add_indices(self, indices)

    if state == false {
        resize(&self.vertices, len(self.vertices) - len(vertices))
    }

    if state == true {
        texture_table_add(&self.textures, texture)
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
