package graphics

State :: struct
{
    rects: Rect_Batch,
}

start :: proc() -> State
{
    value := State {}

    VERTEX_ARRAY_DEFAULT = vertex_array_make_default()

    VERTEX_LAYOUT_RECT = vertex_layout_make_rect()
    VERTEX_BUFFER_RECT = vertex_buffer_make_rect(VERTEX_LAYOUT_RECT, VERTEX_BUFFER_RECT_ITEMS)

    INDEX_BUFFER_RECT = index_buffer_make_rect(INDEX_BUFFER_RECT_ITEMS)

    SHADER_RECT = shader_make_rect()
    SHADER_MSDF = shader_make_msdf()

    SAMPLER_SHARP  = sampler_make_sharp()
    SAMPLER_SMOOTH = sampler_make_smooth()

    TEXTURE_WHITE = texture_make_white()

    value.rects = rect_batch_make()

    return value
}

stop :: proc(self: ^State)
{
    rect_batch_destroy(&self.rects)

    texture_destroy(&TEXTURE_WHITE)

    sampler_destroy(&SAMPLER_SMOOTH)
    sampler_destroy(&SAMPLER_SHARP)

    shader_destroy(&SHADER_MSDF)
    shader_destroy(&SHADER_RECT)

    index_buffer_destroy(&INDEX_BUFFER_RECT)

    vertex_buffer_destroy(&VERTEX_BUFFER_RECT)

    vertex_array_destroy(&VERTEX_ARRAY_DEFAULT)
}

begin :: proc(self: ^State, view: ^View)
{
    set_viewport(view.viewport)

    rect_batch_begin(&self.rects, view, &SHADER_MSDF)
}

end :: proc(self: ^State)
{
    clear_background()

    rect_batch_end(&self.rects)
}

paint_rect :: proc(self: ^State, rect: [4]f32, color: [4]f32, scale: [2]f32)
{
    rect_batch_add(&self.rects, rect, color, scale,
        {}, &TEXTURE_WHITE, &SAMPLER_SHARP)
}

paint_rect_rotated :: proc(self: ^State, rect: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32, scale: [2]f32)
{
    rect_batch_add_rotated(&self.rects, rect, color, scale,
        angle, pivot, {}, &TEXTURE_WHITE, &SAMPLER_SHARP)
}

paint_sprite :: proc(self: ^State, rect: [4]f32, texture: ^Texture, sprite: [4]int, color: [4]f32, scale: [2]f32)
{
    rect_batch_add(&self.rects, rect, color, scale,
        sprite, texture, &SAMPLER_SHARP)
}

paint_sprite_rotated :: proc(self: ^State, rect: [4]f32, texture: ^Texture, sprite: [4]int, color: [4]f32, angle: f32, pivot: [2]f32, scale: [2]f32)
{
    rect_batch_add_rotated(&self.rects, rect, color, scale,
        angle, pivot, sprite, texture, &SAMPLER_SHARP)
}

paint_glyph :: proc(self: ^State, rect: [4]f32, texture: ^Texture, glyph: [4]int, color: [4]f32, scale: [2]f32)
{
    rect_batch_add(&self.rects, rect, color, scale,
        glyph, texture, &SAMPLER_SMOOTH)
}

paint_glyph_rotated :: proc(self: ^State, rect: [4]f32, texture: ^Texture, glyph: [4]int, color: [4]f32, angle: f32, pivot: [2]f32, scale: [2]f32)
{
    rect_batch_add_rotated(&self.rects, rect, color, scale,
        angle, pivot, glyph, texture, &SAMPLER_SMOOTH)
}
