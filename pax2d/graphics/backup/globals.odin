package graphics

//
// Values
//

VERTEX_BUFFER_RECT_ITEMS :: 4 * 4096
INDEX_BUFFER_RECT_ITEMS  :: 6 * 4096

VERTEX_ARRAY_DEFAULT := Vertex_Array {}

VERTEX_LAYOUT_RECT := Vertex_Layout {}
VERTEX_BUFFER_RECT := Vertex_Buffer {}
INDEX_BUFFER_RECT  := Index_Buffer {}

SAMPLER_SHARP  := Sampler {}
SAMPLER_SMOOTH := Sampler {}

TEXTURE_WHITE := Texture {}

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
    value, _ := texture_make_from_image(&Image {
        format = .IMAGE_RGB,
        bytes  = 1,
        items  = {1, 1},
        data   = {255, 255, 255},
    })

    return value
}
