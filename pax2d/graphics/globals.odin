package graphics

//
// Values
//

SHADER_RECT_VERTEX ::
`
#version 330 core

layout (location = 0) in vec2  a_point;
layout (location = 1) in vec4  a_color;
layout (location = 2) in vec2  a_texel;
layout (location = 3) in float a_texture;

out vec4  v_color;
out vec2  v_texel;
out float v_texture;

void main()
{
    v_color   = a_color;
    v_texel   = a_texel;
    v_texture = a_texture;

    gl_Position = vec4(a_point, 0, 1);
}
`

SHADER_RECT_PIXEL ::
`
#version 330 core

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

VERTEX_BUFFER_RECT_ITEMS :: 6 * 1024 

VERTEX_ARRAY_DEFAULT := Vertex_Array {}

VERTEX_LAYOUT_RECT := Vertex_Layout {}
VERTEX_BUFFER_RECT := Vertex_Buffer {}

SHADER_RECT := Shader {}

SAMPLER_SHARP  := Sampler {}
SAMPLER_SMOOTH := Sampler {}

TEXTURE_WHITE := Texture {}

//
// Types
//

Rect_Vertex :: struct
{
    point:   [2]f32,
    color:   [4]f32,
    texel:   [2]f32,
    texture: f32,
}

//
// Procs
//

vertex_array_make_default :: proc() -> Vertex_Array
{
    value, state := vertex_array_make()

    if state == true {
        vertex_array_bind(&value)
    }

    return value
}

vertex_layout_make_rect :: proc() -> Vertex_Layout
{
    layout := Vertex_Layout {}

    vertex_layout_add_attrib(&layout, .TYPE_F32_VEC2) // point
    vertex_layout_add_attrib(&layout, .TYPE_F32_VEC4) // color
    vertex_layout_add_attrib(&layout, .TYPE_F32_VEC2) // texel
    vertex_layout_add_attrib(&layout, .TYPE_F32)      // texture

    return layout
}

vertex_buffer_make_rect:: proc(layout: Vertex_Layout, items: int) -> Vertex_Buffer
{
    value, _ := vertex_buffer_make_with_storage(
        layout, items)

    return value
}

shader_make_rect :: proc() -> Shader
{
    builder := Shader_Builder {}

    shader_add_stage_from_source(&builder, .STAGE_VERTEX, SHADER_RECT_VERTEX)
    shader_add_stage_from_source(&builder, .STAGE_PIXEL,  SHADER_RECT_PIXEL)

    value, _ := shader_make_from_builder(&builder)

    return value
}

sampler_make_sharp :: proc() -> Sampler
{
    value, state := sampler_make()

    if state == true {
        sampler_set_filtering(&value, .FILTER_MIN, .MODE_NEAREST)
        sampler_set_filtering(&value, .FILTER_MAG, .MODE_NEAREST)

        sampler_set_wrapping(&value, .AXIS_X, .MODE_REPEAT)
        sampler_set_wrapping(&value, .AXIS_Y, .MODE_REPEAT)
    }

    return value
}

sampler_make_smooth :: proc() -> Sampler
{
    value, state := sampler_make()

    if state == true {
        sampler_set_filtering(&value, .FILTER_MIN, .MODE_LINEAR)
        sampler_set_filtering(&value, .FILTER_MAG, .MODE_LINEAR)

        sampler_set_wrapping(&value, .AXIS_X, .MODE_REPEAT)
        sampler_set_wrapping(&value, .AXIS_Y, .MODE_REPEAT)
    }

    return value
}

texture_make_white :: proc() -> Texture
{
    value, state := texture_make_with_storage(.LAYOUT_RGB, {1, 1})

    if state == true {
        texture_write_all(&value, .LAYOUT_RGB, {255, 255, 255})
    }

    return value
}

//
// SHADER_PIXEL_CIRCLE
//

/*
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 localCoord = fragCoord / iResolution.xy * 2.0 - 1.0;
    
    float distance = length(localCoord);
    float strength = 1.0 - distance;
    
    float thickness = 1.0;
    float blurness  = 0.005;
    
    vec3 color = vec3(smoothstep(0.0, blurness, strength));
    
    color *= vec3(smoothstep(thickness + blurness, thickness, strength));
    
    fragColor = vec4(color, 1.0) * vec4(0.8, 0.3, 0.2, 0.1);
}
*/
