package graphics

//
// Values
//

TEXTURE_WHITE := Texture {}

SAMPLER_SHARP := Sampler {}

//
// Types
//

State :: struct
{
    batch: Quad_Batch,
}

//
// Procs
//

start :: proc() -> (State, bool)
{
    value := State {}
    state := true

    value.batch, state = quad_batch_make(8192)

    TEXTURE_WHITE = texture_white()
    SAMPLER_SHARP = sampler_sharp()

    return value, state
}

stop :: proc(self: ^State)
{
    quad_batch_destroy(&self.batch)
}

begin :: proc(self: ^State)
{
    quad_batch_clear(&self.batch)
}

end :: proc(self: ^State)
{
    clear_buffer_color()

    quad_batch_write(&self.batch)
}

paint_rect_rotated :: proc(self: ^State, bounds: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32 = {0, 0}, scale: [2]f32 = {1, 1})
{
    quad_batch_add(&self.batch, {
        { vertex_coords = bounds.xy,                 vertex_color = color, },
        { vertex_coords = bounds.xy + {0, bounds.w}, vertex_color = color, },
        { vertex_coords = bounds.xy + {bounds.z, 0}, vertex_color = color, },
        { vertex_coords = bounds.xy + bounds.zw,     vertex_color = color, },
    }, {
        texture = &TEXTURE_WHITE,
        sampler = &SAMPLER_SHARP,
    })
}

texture_white :: proc() -> Texture
{
    value, state := texture_alloc(.TEXTURE_RGB, {1, 1})

    if state == false { return value }

    state = texture_write_all(&value, .TEXTURE_RGB, {255, 255, 255})

    if state == false { texture_destroy(&value) }

    return value
}

sampler_sharp :: proc() -> Sampler
{
    value, state := sampler_make()

    if state == false { return value }

    sampler_set_filtering(&value, .FILTER_MIN, .MODE_NEAREST)
    sampler_set_filtering(&value, .FILTER_MAG, .MODE_NEAREST)

    sampler_set_wrapping(&value, .AXIS_X, .MODE_REPEAT)
    sampler_set_wrapping(&value, .AXIS_Y, .MODE_REPEAT)

    return value
}