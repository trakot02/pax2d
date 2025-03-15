package graphics

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

    value.batch, state = quad_batch_make()

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
    clear_buffer_any()

    quad_batch_write(&self.batch)
}

paint_rect_rotated :: proc(self: ^State, bounds: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32 = {0, 0}, scale: [2]f32 = {1, 1})
{
    quad_batch_add(&self.batch, {
        { vertex_coords = bounds.xy,                 vertex_color = color, },
        { vertex_coords = bounds.xy + {0, bounds.w}, vertex_color = color, },
        { vertex_coords = bounds.xy + {bounds.z, 0}, vertex_color = color, },
        { vertex_coords = bounds.xy + bounds.zw,     vertex_color = color, },
    })
}
