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

uniform mat4 u_view;

void main()
{
    v_color   = a_color;
    v_texel   = a_texel;
    v_texture = a_texture;

    gl_Position = u_view * vec4(a_point, 0, 1);
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
    vec4 color = vec4(1);

    switch ( index ) {
        case 0: { color = texture(u_samplers[0], v_texel); } break;
        case 1: { color = texture(u_samplers[1], v_texel); } break;
        case 2: { color = texture(u_samplers[2], v_texel); } break;
        case 3: { color = texture(u_samplers[3], v_texel); } break;
        case 4: { color = texture(u_samplers[4], v_texel); } break;
        case 5: { color = texture(u_samplers[5], v_texel); } break;
        case 6: { color = texture(u_samplers[6], v_texel); } break;
        case 7: { color = texture(u_samplers[7], v_texel); } break;
    }

    p_color = color * v_color;
}
`

SHADER_MSDF_VERTEX :: SHADER_RECT_VERTEX

SHADER_MSDF_PIXEL ::
`
#version 330 core

in vec4  v_color;
in vec2  v_texel;
in float v_texture;

out vec4 p_color;

uniform float threshold = 0.59;
uniform float smoothing = 0.01;

uniform sampler2D u_samplers[8];

float median_vec3_comps(float x, float y, float z);
float median_vec3(vec3 v);

void main()
{
    int  index = int(v_texture);
    vec4 color = vec4(1);

    switch ( index ) {
        case 0: { color = texture(u_samplers[0], v_texel); } break;
        case 1: { color = texture(u_samplers[1], v_texel); } break;
        case 2: { color = texture(u_samplers[2], v_texel); } break;
        case 3: { color = texture(u_samplers[3], v_texel); } break;
        case 4: { color = texture(u_samplers[4], v_texel); } break;
        case 5: { color = texture(u_samplers[5], v_texel); } break;
        case 6: { color = texture(u_samplers[6], v_texel); } break;
        case 7: { color = texture(u_samplers[7], v_texel); } break;
    }

    float start = threshold;
    float stop  = threshold + smoothing;

    float dist = median_vec3(color.xyz);

    float alpha = smoothstep(start, stop, dist);

    p_color = vec4(v_color.rgb, v_color.a * alpha);
}

float median_vec3_comps(float x, float y, float z)
{
    return max(min(x, y), min(max(x, y), z));
}

float median_vec3(vec3 v)
{
    return median_vec3_comps(v.x, v.y, v.z);
}
`

VERTEX_BUFFER_RECT_ITEMS :: 4 * 4096 
INDEX_BUFFER_RECT_ITEMS  :: 6 * 4096

VERTEX_ARRAY_DEFAULT := Vertex_Array {}

VERTEX_LAYOUT_RECT := Vertex_Layout {}
VERTEX_BUFFER_RECT := Vertex_Buffer {}

INDEX_BUFFER_RECT := Index_Buffer {}

SHADER_RECT := Shader {}
SHADER_MSDF := Shader {}

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

index_buffer_make_rect :: proc(items: int) -> Index_Buffer
{
    value, _ := index_buffer_make_with_storage(
        size_of(u32), items)

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

shader_make_msdf :: proc() -> Shader
{
    builder := Shader_Builder {}

    shader_add_stage_from_source(&builder, .STAGE_VERTEX, SHADER_MSDF_VERTEX)
    shader_add_stage_from_source(&builder, .STAGE_PIXEL,  SHADER_MSDF_PIXEL)

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
        sampler_set_filtering(&value, .FILTER_MIN, .MODE_NEAREST)
        sampler_set_filtering(&value, .FILTER_MAG, .MODE_LINEAR)

        sampler_set_wrapping(&value, .AXIS_X, .MODE_REPEAT)
        sampler_set_wrapping(&value, .AXIS_Y, .MODE_REPEAT)
    }

    return value
}

texture_make_white :: proc() -> Texture
{
    value, _ := texture_make_from_image(&Image {
        format = .IMAGE_RGB,
        bytes  = 1,
        items  = {1, 1},
        data   = {255, 255, 255},
    })

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
