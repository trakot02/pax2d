package graphics

import "core:log"

import gl "./opengl"

//
// Values
//

VERTEX_BUFFER_LIMIT :: 4096

VERTEX_ARRAY_DEFAULT := gl.Vertex_Array {}

VERTEX_LAYOUT_DEFAULT := gl.Vertex_Layout {}
VERTEX_BUFFER_DEFAULT := gl.Vertex_Buffer {}

SHADER_DEFAULT := gl.Shader {}

SAMPLER_SHARP  := gl.Sampler {}
SAMPLER_SMOOTH := gl.Sampler {}

TEXTURE_WHITE := gl.Texture {}

//
// Types
//

Vertex :: struct
{
    point:   [2]f32,
    color:   [4]f32,
    texel:   [2]f32,
    texture: f32,
}

Batch :: struct
{
    view: ^View,

    textures: gl.Texture_Bundle,
    samplers: gl.Sampler_Bundle,

    vertices: [dynamic]Vertex,
}

//
// Procs
//

start :: proc()
{
    VERTEX_ARRAY_DEFAULT = vertex_array_make_default()

    VERTEX_LAYOUT_DEFAULT = vertex_layout_make_default()
    VERTEX_BUFFER_DEFAULT = vertex_buffer_make_default(VERTEX_LAYOUT_DEFAULT)

    SHADER_DEFAULT = shader_make_default()

    SAMPLER_SHARP  = sampler_make_sharp()
    SAMPLER_SMOOTH = sampler_make_smooth()

    TEXTURE_WHITE = texture_make_white()
}

stop :: proc()
{
    gl.texture_destroy(&TEXTURE_WHITE)

    gl.sampler_destroy(&SAMPLER_SMOOTH)
    gl.sampler_destroy(&SAMPLER_SHARP)

    gl.shader_destroy(&SHADER_DEFAULT)

    gl.vertex_buffer_destroy(&VERTEX_BUFFER_DEFAULT)

    gl.vertex_array_destroy(&VERTEX_ARRAY_DEFAULT)
}

set_viewport :: proc(rect: [4]int)
{
    gl.set_viewport(rect)
}

set_background_color :: proc(color: [3]f32)
{
    gl.set_background_color(color)
}

batch_make :: proc(allocator := context.allocator) -> Batch
{
    value := Batch {}

    value.vertices = make([dynamic]Vertex, allocator)

    return value
}

batch_destroy :: proc(self: ^Batch)
{
    delete(self.vertices)

    self.vertices = {}
}

batch_begin :: proc(self: ^Batch, view: ^View)
{
    self.view = view
}

batch_end :: proc(self: ^Batch)
{
    items := len(self.vertices)
    start := 0
    stop  := 0

    gl.clear()

    gl.shader_bind(&SHADER_DEFAULT)

    gl.sampler_bundle_bind(&self.samplers)
    gl.texture_bundle_bind(&self.textures)

    for items > 0 {
        delta := min(items, VERTEX_BUFFER_LIMIT)

        items -= delta
        stop  += delta

        gl.vertex_buffer_write_to_front(&VERTEX_BUFFER_DEFAULT,
                self.vertices[start:stop])

        gl.paint(&VERTEX_BUFFER_DEFAULT)

        gl.vertex_buffer_clear(&VERTEX_BUFFER_DEFAULT)

        start = stop
    }

    gl.sampler_bundle_clear(&self.samplers)
    gl.texture_bundle_clear(&self.textures)

    gl.texture_bundle_unbind()
    gl.sampler_bundle_unbind()

    gl.shader_unbind()

    clear(&self.vertices)
}

batch_rect :: proc(self: ^Batch, rect: [4]f32, color: [4]f32, scale: [2]f32) -> bool
{
    verts := [4]Vertex {}
    items := len(self.vertices)

    index := -1
    other := -1
    state := true

    index, state = gl.texture_bundle_add(&self.textures, &TEXTURE_WHITE)

    if state == false { return false }

    other, state = gl.sampler_bundle_add(&self.samplers, &SAMPLER_SHARP)

    if state == false { return false }
    if index != other { return false }

    for &item in verts {
        item.point   = {rect.x, rect.y}
        item.texel   = {0, 0}

        item.color   = color
        item.texture = f32(index)
    }

    verts[1].point.x += rect.z
    verts[2].point.y += rect.w
    verts[3].point.x += rect.z
    verts[3].point.y += rect.w

    verts[1].texel.x += 1
    verts[2].texel.y += 1
    verts[3].texel.x += 1
    verts[3].texel.y += 1

    indxs := [6]int {0, 2, 1, 1, 2, 3}

    for item in indxs {
        _, error := append(&self.vertices, verts[item])

        if error != nil {
            log.errorf("Render_Batch: Unable to add rect vertex")

            resize(&self.vertices, items)

            return false
        }
    }

    return true
}

batch_rect_rotated :: proc(self: ^Batch, rect: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32) -> bool
{
    // TODO(gio): inserts the vertices inside the state next to the same ones that share the same texture.

    return false
}

batch_rect_general :: proc(self: ^Batch, rect: [4]f32, color: [4]f32, scale: [2]f32, angle: f32, pivot: [2]f32) -> bool
{
    // TODO(gio): inserts the vertices inside the state next to the same ones that share the same texture.

    return false
}

@(private)
vertex_array_make_default :: proc() -> gl.Vertex_Array
{
    value, state := gl.vertex_array_make()

    if state == true {
        gl.vertex_array_bind(&value)
    }

    return value
}

@(private)
vertex_layout_make_default :: proc() -> gl.Vertex_Layout
{
    layout := gl.Vertex_Layout {}

    gl.vertex_layout_add_attrib(&layout, .TYPE_F32_VEC2) // point
    gl.vertex_layout_add_attrib(&layout, .TYPE_F32_VEC4) // color
    gl.vertex_layout_add_attrib(&layout, .TYPE_F32_VEC2) // texel
    gl.vertex_layout_add_attrib(&layout, .TYPE_F32)      // texture

    return layout
}

@(private)
vertex_buffer_make_default :: proc(layout: gl.Vertex_Layout) -> gl.Vertex_Buffer
{
    value, state := gl.vertex_buffer_make_with_storage(
        layout, VERTEX_BUFFER_LIMIT)

    if state == false {
        log.debugf("Graphics: Unable to create default vertex buffer")
    }

    return value
}

@(private)
shader_make_default :: proc() -> gl.Shader
{
    builder := gl.Shader_Builder {}

    gl.shader_add_stage_from_source(&builder, .STAGE_VERTEX, SHADER_VERTEX_DEFAULT)
    gl.shader_add_stage_from_source(&builder, .STAGE_PIXEL,  SHADER_PIXEL_DEFAULT)

    value, state := gl.shader_make_from_builder(&builder)

    if state == false {
        log.debugf("Graphics: Unable to create default shader")
    }

    return value
}

@(private)
sampler_make_sharp :: proc() -> gl.Sampler
{
    value, state := gl.sampler_make()

    if state == false {
        log.debugf("Graphics: Unable to create default sampler (sharp)")

        return value
    }

    gl.sampler_set_filtering(&value, .FILTER_MIN, .MODE_NEAREST)
    gl.sampler_set_filtering(&value, .FILTER_MAG, .MODE_NEAREST)

    gl.sampler_set_wrapping(&value, .AXIS_X, .MODE_REPEAT)
    gl.sampler_set_wrapping(&value, .AXIS_Y, .MODE_REPEAT)

    return value
}

@(private)
sampler_make_smooth :: proc() -> gl.Sampler
{
    value, state := gl.sampler_make()

    if state == false {
        log.debugf("Graphics: Unable to create default sampler (smooth)")

        return value
    }

    gl.sampler_set_filtering(&value, .FILTER_MIN, .MODE_LINEAR)
    gl.sampler_set_filtering(&value, .FILTER_MAG, .MODE_LINEAR)

    gl.sampler_set_wrapping(&value, .AXIS_X, .MODE_REPEAT)
    gl.sampler_set_wrapping(&value, .AXIS_Y, .MODE_REPEAT)

    return value
}

@(private)
texture_make_white :: proc() -> gl.Texture
{
    value, state := gl.texture_make_with_storage(.LAYOUT_RGB, {1, 1})

    if state == false {
        log.debugf("Graphics: Unable to create default texture (white)")

        return value
    }

    gl.texture_write_all(&value, .LAYOUT_RGB, {255, 255, 255})

    return value
}

@(private)
SHADER_VERTEX_DEFAULT ::
`#version 330 core

layout (location = 0) in vec2  b_point;
layout (location = 1) in vec4  b_color;
layout (location = 2) in vec2  b_texel;
layout (location = 3) in float b_texture;

out vec4  v_color;
out vec2  v_texel;
out float v_texture;

void main()
{
    v_color   = b_color;
    v_texel   = b_texel;
    v_texture = b_texture;

    gl_Position = vec4(b_point, 0, 1);
}
`

@(private)
SHADER_PIXEL_DEFAULT ::
`#version 330 core

in vec4  v_color;
in vec2  v_texel;
in float v_texture;

out vec4 p_color;

uniform sampler2D u_samplers[8];

void main()
{
    int  index = int(v_texture);
    vec4 color = texture(u_samplers[index], v_texel);

    p_color = color * v_color;
}
`
