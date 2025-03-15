package graphics

import gl "./opengl"

//
// Values
//

VERTEX_ATTRIB_MAX :: gl.VERTEX_ATTRIB_MAX
SHADER_STAGE_MAX  :: gl.SHADER_STAGE_MAX
TEXTURE_SLOT_MAX  :: gl.TEXTURE_SLOT_MAX

//
// Types
//

Blending :: gl.Blending

Vertex_Attrib_Type :: gl.Vertex_Attrib_Type
Vertex_Attrib      :: gl.Vertex_Attrib
Vertex_Layout      :: gl.Vertex_Layout
Vertex_Spec        :: gl.Vertex_Spec

Vertex_Buffer  :: gl.Vertex_Buffer
Index_Buffer   :: gl.Index_Buffer
Uniform_Buffer :: gl.Uniform_Buffer

Sampler_Filter      :: gl.Sampler_Filter
Sampler_Filter_Mode :: gl.Sampler_Filter_Mode
Sampler_Wrap_Axis   :: gl.Sampler_Wrap_Axis
Sampler_Wrap_Mode   :: gl.Sampler_Wrap_Mode
Sampler             :: gl.Sampler

Texture_Format :: gl.Texture_Format
Texture        :: gl.Texture

Mesh :: gl.Mesh

Shader_Stage   :: gl.Shader_Stage
Shader_Builder :: gl.Shader_Builder
Shader         :: gl.Shader

//
// Procs
//

set_clear_color    :: gl.set_clear_color
set_multi_sampling :: gl.set_multi_sampling
set_depth_testing  :: gl.set_depth_testing
set_blending       :: gl.set_blending
set_viewport       :: gl.set_viewport

clear_buffer_color :: gl.clear_buffer_color
clear_buffer_depth :: gl.clear_buffer_depth
clear_buffer_any   :: gl.clear_buffer_any

vertex_layout_clear      :: gl.vertex_layout_clear
vertex_layout_add        :: gl.vertex_layout_add
vertex_layout_get_kind   :: gl.vertex_layout_get_kind
vertex_layout_get_mult   :: gl.vertex_layout_get_mult
vertex_layout_get_offset :: gl.vertex_layout_get_offset
vertex_layout_get_stride :: gl.vertex_layout_get_stride

vertex_spec_make    :: gl.vertex_spec_make
vertex_spec_destroy :: gl.vertex_spec_destroy
vertex_spec_apply   :: gl.vertex_spec_apply

vertex_buffer_make              :: gl.vertex_buffer_make
vertex_buffer_make_with_storage :: gl.vertex_buffer_alloc
vertex_buffer_destroy           :: gl.vertex_buffer_destroy
vertex_buffer_get_size          :: gl.vertex_buffer_get_size
vertex_buffer_clear             :: gl.vertex_buffer_clear
vertex_buffer_set_storage       :: gl.vertex_buffer_realloc
vertex_buffer_write_all         :: gl.vertex_buffer_write_all
vertex_buffer_write_to_front    :: gl.vertex_buffer_write_to_front

index_buffer_make              :: gl.index_buffer_make
index_buffer_make_with_storage :: gl.index_buffer_alloc
index_buffer_destroy           :: gl.index_buffer_destroy
index_buffer_get_size          :: gl.index_buffer_get_size
index_buffer_clear             :: gl.index_buffer_clear
index_buffer_set_storage       :: gl.index_buffer_realloc
index_buffer_write_all         :: gl.index_buffer_write_all
index_buffer_write_to_front    :: gl.index_buffer_write_to_front

uniform_buffer_make              :: gl.uniform_buffer_make
uniform_buffer_make_with_storage :: gl.uniform_buffer_alloc
uniform_buffer_destroy           :: gl.uniform_buffer_destroy
uniform_buffer_clear             :: gl.uniform_buffer_clear
uniform_buffer_set_storage       :: gl.uniform_buffer_realloc
uniform_buffer_write_all         :: gl.uniform_buffer_write_all
uniform_buffer_write_to_front    :: gl.uniform_buffer_write_to_front

sampler_make              :: gl.sampler_make
sampler_destroy           :: gl.sampler_destroy
sampler_set_filtering     :: gl.sampler_set_filtering
sampler_set_wrapping      :: gl.sampler_set_wrapping

texture_make              :: gl.texture_make
texture_make_with_storage :: gl.texture_alloc
texture_destroy           :: gl.texture_destroy
texture_get_size          :: gl.texture_get_size
texture_set_storage       :: gl.texture_realloc
texture_write_all         :: gl.texture_write_all
texture_normalize_coords  :: gl.texture_normalize_coords

mesh_make           :: gl.mesh_make
mesh_destroy        :: gl.mesh_destroy
mesh_clear          :: gl.mesh_clear
mesh_apply_layout   :: gl.mesh_apply_layout
mesh_write_vertices :: gl.mesh_write_vertices
mesh_write_indices  :: gl.mesh_write_indices

shader_builder_clear      :: gl.shader_builder_clear
shader_builder_add_stage  :: gl.shader_builder_add_stage
shader_build              :: gl.shader_build
shader_make               :: gl.shader_make
shader_make_from_builder  :: gl.shader_make_from_builder
shader_destroy            :: gl.shader_destroy
shader_find_uniform       :: gl.shader_find_uniform
shader_execute            :: gl.shader_execute

/*
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
    value := Texture {}
    image := Image {}
    state := image_read_from_file(&image, filename)

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
*/
