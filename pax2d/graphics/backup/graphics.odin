package graphics

Sampler_Cache :: struct
{

}

State :: struct
{
    batch: Rect_Batch,
}

start :: proc() -> State
{
    value := State {}

    VERTEX_ARRAY_DEFAULT = vertex_array_make_default()

    VERTEX_LAYOUT_RECT = vertex_layout_make_rect()
    VERTEX_BUFFER_RECT = vertex_buffer_make_rect(VERTEX_LAYOUT_RECT, VERTEX_BUFFER_RECT_ITEMS)
    INDEX_BUFFER_RECT  = index_buffer_make_rect(INDEX_BUFFER_RECT_ITEMS)

    SHADER_RECT = shader_make_rect()

    SAMPLER_SHARP  = sampler_make_sharp()
    SAMPLER_SMOOTH = sampler_make_smooth()

    TEXTURE_WHITE = texture_make_white()

    value.batch = rect_batch_make()

    return value
}

stop :: proc(self: ^State)
{
    rect_batch_destroy(&self.batch)

    texture_destroy(&TEXTURE_WHITE)

    sampler_destroy(&SAMPLER_SMOOTH)
    sampler_destroy(&SAMPLER_SHARP)

    shader_destroy(&SHADER_RECT)

    index_buffer_destroy(&INDEX_BUFFER_RECT)
    vertex_buffer_destroy(&VERTEX_BUFFER_RECT)

    vertex_array_destroy(&VERTEX_ARRAY_DEFAULT)
}

begin :: proc(self: ^State, view: ^View)
{
    rect_batch_clear(&self.batch)

    rect_batch_set_view(&self.batch, view)
    rect_batch_set_shader(&self.batch, &SHADER_RECT)

    set_viewport(view.viewport)
}

end :: proc(self: ^State)
{
    clear_background()

    rect_batch_apply(&self.batch)
}

paint_rect :: proc(self: ^State, shape: [4]f32, color: [4]f32, scale: [2]f32)
{
    rect_batch_add(&self.batch, shape, color, scale,
        {}, &TEXTURE_WHITE, &SAMPLER_SHARP)
}

paint_rect_rotated :: proc(self: ^State, shape: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32, scale: [2]f32)
{
    rect_batch_add_rotated(&self.batch, shape, color, scale,
        angle, pivot, {}, &TEXTURE_WHITE, &SAMPLER_SHARP)
}

paint_sprite :: proc(self: ^State, section: [4]int, texture: ^Texture, shape: [4]f32, color: [4]f32, scale: [2]f32)
{
    rect_batch_add(&self.batch, shape, color, scale,
        section, texture, &SAMPLER_SHARP)
}

paint_sprite_rotated :: proc(self: ^State, section: [4]int, texture: ^Texture, shape: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32, scale: [2]f32)
{
    rect_batch_add_rotated(&self.batch, shape, color, scale,
        angle, pivot, section, texture, &SAMPLER_SHARP)
}
