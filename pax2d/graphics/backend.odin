package graphics

import gl "./opengl"

//
// Types
//

Vertex_Array :: gl.Vertex_Array

Vertex_Buffer :: gl.Vertex_Buffer
Vertex_Layout :: gl.Vertex_Layout

Index_Buffer  :: gl.Index_Buffer

Sampler_Filter      :: gl.Sampler_Filter
Sampler_Filter_Mode :: gl.Sampler_Filter_Mode
Sampler_Wrap_Axis   :: gl.Sampler_Wrap_Axis
Sampler_Wrap_Mode   :: gl.Sampler_Wrap_Mode
Sampler             :: gl.Sampler
Sampler_Bundle      :: gl.Sampler_Bundle

Texture_Format :: gl.Texture_Format
Texture        :: gl.Texture
Texture_Bundle :: gl.Texture_Bundle

Shader_Stage_Type :: gl.Shader_Stage_Type
Shader_Value_Type :: gl.Shader_Value_Type
Shader            :: gl.Shader
Shader_Builder    :: gl.Shader_Builder

//
// Procs
//

vertex_array_make    :: gl.vertex_array_make
vertex_array_destroy :: gl.vertex_array_destroy
vertex_array_bind    :: gl.vertex_array_bind
vertex_array_unbind  :: gl.vertex_array_unbind

set_viewport    :: gl.set_viewport
set_clear_color :: gl.set_clear_color

clear_background        :: gl.clear_background
paint_triangles         :: gl.paint_triangles
paint_triangles_indexed :: gl.paint_triangles_indexed

vertex_buffer_make              :: gl.vertex_buffer_make
vertex_buffer_make_with_storage :: gl.vertex_buffer_make_with_storage
vertex_buffer_destroy           :: gl.vertex_buffer_destroy
vertex_buffer_bind              :: gl.vertex_buffer_bind
vertex_buffer_unbind            :: gl.vertex_buffer_unbind
vertex_buffer_clear             :: gl.vertex_buffer_clear
vertex_buffer_set_storage       :: gl.vertex_buffer_set_storage
vertex_buffer_set_layout        :: gl.vertex_buffer_set_layout
vertex_buffer_write_all         :: gl.vertex_buffer_write_all
vertex_buffer_write_to_front    :: gl.vertex_buffer_write_to_front
vertex_buffer_write_to_range    :: gl.vertex_buffer_write_to_range

vertex_layout_add_attrib        :: gl.vertex_layout_add_attrib
vertex_layout_get_attrib_class  :: gl.vertex_layout_get_attrib_class
vertex_layout_get_attrib_items  :: gl.vertex_layout_get_attrib_items
vertex_layout_get_attrib_offset :: gl.vertex_layout_get_attrib_offset
vertex_layout_get_stride        :: gl.vertex_layout_get_stride

index_buffer_make              :: gl.index_buffer_make
index_buffer_make_with_storage :: gl.index_buffer_make_with_storage
index_buffer_destroy           :: gl.index_buffer_destroy
index_buffer_bind              :: gl.index_buffer_bind
index_buffer_unbind            :: gl.index_buffer_unbind
index_buffer_clear             :: gl.index_buffer_clear
index_buffer_set_storage       :: gl.index_buffer_set_storage
index_buffer_write_all         :: gl.index_buffer_write_all
index_buffer_write_to_front    :: gl.index_buffer_write_to_front
index_buffer_write_to_range    :: gl.index_buffer_write_to_range

sampler_make            :: gl.sampler_make
sampler_destroy         :: gl.sampler_destroy
sampler_bind            :: gl.sampler_bind
sampler_unbind          :: gl.sampler_unbind
sampler_set_filtering   :: gl.sampler_set_filtering
sampler_set_wrapping    :: gl.sampler_set_wrapping
sampler_bundle_clear    :: gl.sampler_bundle_clear
sampler_bundle_index_of :: gl.sampler_bundle_index_of
sampler_bundle_add      :: gl.sampler_bundle_add
sampler_bundle_bind     :: gl.sampler_bundle_bind
sampler_bundle_unbind   :: gl.sampler_bundle_unbind

texture_make              :: gl.texture_make
texture_make_with_storage :: gl.texture_make_with_storage
texture_destroy           :: gl.texture_destroy
texture_bind              :: gl.texture_bind
texture_unbind            :: gl.texture_unbind
texture_set_storage       :: gl.texture_set_storage
texture_write_all         :: gl.texture_write_all
texture_write_to_range    :: gl.texture_write_to_range
texture_normalize         :: gl.texture_normalize
texture_bundle_clear      :: gl.texture_bundle_clear
texture_bundle_index_of   :: gl.texture_bundle_index_of
texture_bundle_add        :: gl.texture_bundle_add
texture_bundle_bind       :: gl.texture_bundle_bind
texture_bundle_unbind     :: gl.texture_bundle_unbind

shader_make                  :: gl.shader_make
shader_make_from_builder     :: gl.shader_make_from_builder
shader_destroy               :: gl.shader_destroy
shader_bind                  :: gl.shader_bind
shader_unbind                :: gl.shader_unbind
shader_write_i32_array       :: gl.shader_write_i32_array
shader_write_i32             :: gl.shader_write_i32
shader_write_i32_vec2        :: gl.shader_write_i32_vec2
shader_write_i32_vec3        :: gl.shader_write_i32_vec3
shader_write_i32_vec4        :: gl.shader_write_i32_vec4
shader_write_f32_array       :: gl.shader_write_f32_array
shader_write_f32             :: gl.shader_write_f32
shader_write_f32_vec2        :: gl.shader_write_f32_vec2
shader_write_f32_vec3        :: gl.shader_write_f32_vec3
shader_write_f32_vec4        :: gl.shader_write_f32_vec4
shader_write_f32_mat4        :: gl.shader_write_f32_mat4
shader_add_stage_from_source :: gl.shader_add_stage_from_source
shader_build                 :: gl.shader_build

texture_write_image_all :: proc(self: ^Texture, image: ^Image) -> bool
{
    format := IMAGE_TO_TEXTURE_FORMAT[image.format]

    if self.format == format {
        return texture_write_all(self, format, image.data)
    }

    return false
}

texture_write_image_to_range :: proc(self: ^Texture, image: ^Image, range: [4]int) -> bool
{
    // TODO(gio): implement using texture_write_range

    assert(false)

    return false
}

texture_make_from_image :: proc(image: ^Image) -> (Texture, bool)
{
    format := IMAGE_TO_TEXTURE_FORMAT[image.format]

    if format == .TEXTURE_NONE { return {}, false }

    value, state := texture_make_with_storage(format, image.items)

    if state == false { return value, state }

    state = texture_write_all(&value, format, image.data)

    if state == false {
        texture_destroy(&value)
    }

    return value, state
}

texture_make_from_file :: proc(filename: string) -> (Texture, bool)
{
    value        := Texture {}
    image, state := image_from_file(filename)

    if state == false { return value, state }

    value, state = texture_make_from_image(&image)

    image_destroy(&image)

    return value, state
}

shader_add_stage_from_file :: proc(self: ^Shader_Builder, type: Shader_Stage_Type, filename: string) -> bool
{
    // TODO(gio): implement loading the file and then deallocate

    assert(false)

    return false
}

@(private)
IMAGE_TO_TEXTURE_FORMAT := [Image_Format]Texture_Format {
    .IMAGE_NONE = .TEXTURE_NONE,
    .IMAGE_RGB  = .TEXTURE_RGB,
    .IMAGE_RGBA = .TEXTURE_RGBA,
}
