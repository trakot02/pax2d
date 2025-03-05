package graphics

import "core:log"

import gl "./opengl"

//
// Values
//

VERTEX_ARRAY_DEFAULT := gl.Vertex_Array {}

VERTEX_BUFFER_LIMIT := 4096

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

State :: struct
{
    view: ^View,

    vertices: [dynamic]Vertex,

    textures: [dynamic]^gl.Texture,
    samplers: [dynamic]^gl.Sampler,
}

//
// Procs
//

start :: proc(allocator := context.allocator) -> State
{
    value := State {}

    value.vertices = make([dynamic]Vertex, allocator)

    value.textures = make([dynamic]^gl.Texture, allocator)
    value.samplers = make([dynamic]^gl.Sampler, allocator)

    VERTEX_ARRAY_DEFAULT := vertex_array_make_default()

    VERTEX_LAYOUT_DEFAULT := vertex_layout_make_default()
    VERTEX_BUFFER_DEFAULT := vertex_buffer_make_default(VERTEX_LAYOUT_DEFAULT)

    SHADER_DEFAULT := shader_make_default()

    SAMPLER_SHARP  := sampler_make_sharp()
    SAMPLER_SMOOTH := sampler_make_smooth()

    TEXTURE_WHITE := texture_make_white()

    return value
}

stop :: proc(self: ^State)
{
    gl.texture_destroy(&TEXTURE_WHITE)
    
    gl.sampler_destroy(&SAMPLER_SMOOTH)
    gl.sampler_destroy(&SAMPLER_SHARP)

    gl.shader_destroy(&SHADER_DEFAULT)

    gl.vertex_buffer_destroy(&VERTEX_BUFFER_DEFAULT)

    delete(self.samplers)
    delete(self.textures)

    delete(self.vertices)

    self.view = nil

    self.vertices = {}
    self.textures = {}
    self.samplers = {}
}

set_viewport :: proc(self: ^State, rect: [4]int)
{
    gl.set_viewport(rect)
}

set_background_color :: proc(self: ^State, color: [3]f32)
{
    gl.set_background_color(color)
}

begin :: proc(self: ^State, view: ^View)
{
    self.view = view
}

end :: proc(self: ^State)
{
    textures := gl.Texture_Bundle {}
    samplers := gl.Sampler_Bundle {}

    start := 0
    stop  := 0

    gl.clear()

    for index in 0 ..< len(self.vertices) {
        // TODO(gio): update start and stop and push stuff to the bundles, when
        //            those are full, paint.

        // gl.vertex_buffer_write_to_front(&VERTEX_BUFFER_DEFAULT,
        //     self.vertices[start:stop])

        gl.paint(&SHADER_DEFAULT, &VERTEX_BUFFER_DEFAULT,
            &textures, &samplers)

        start = stop

        gl.texture_bundle_clear(&textures)
        gl.sampler_bundle_clear(&samplers)
    }

    clear(&self.vertices)
}

paint_rect :: proc(self: ^State, rect: [4]f32, color: [4]f32, scale: [2]f32)
{
    // TODO(gio): inserts the vertices inside the state next to the same ones that share the same texture.
}

paint_rect_rotated :: proc(self: ^State, rect: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32)
{
    // TODO(gio): inserts the vertices inside the state next to the same ones that share the same texture.
}

paint_rect_general :: proc(self: ^State, rect: [4]f32, color: [4]f32, scale: [2]f32, angle: f32, pivot: [2]f32)
{
    // TODO(gio): inserts the vertices inside the state next to the same ones that share the same texture.
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
