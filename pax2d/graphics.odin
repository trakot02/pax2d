package pax2d

import graphics "./graphics"

//
// Types
//

Graphics_State :: graphics.Batch
View           :: graphics.View

//
// Procs
//

graphics_start :: proc() -> Graphics_State
{
    graphics.start()

    return graphics.batch_make()
}

graphics_stop :: proc(self: ^Graphics_State)
{
    graphics.batch_destroy(self)
    graphics.stop()
}

graphics_set_background_color :: proc(color: [3]f32)
{
    graphics.set_background_color(color)
}

graphics_set_viewport :: proc(rect: [4]int)
{
    graphics.set_viewport(rect)
}

graphics_begin :: proc(self: ^Graphics_State, view: ^View)
{
    graphics.batch_begin(self, view)
}

graphics_end :: proc(self: ^Graphics_State)
{
    graphics.batch_end(self)
}

graphics_paint_rect :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, scale: [2]f32 = {1, 1})
{
    graphics.batch_rect(self, rect, color, scale)
}

graphics_paint_rect_rotated :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32 = {0.5, 0.5})
{
    graphics.batch_rect_rotated(self, rect, color, angle, pivot)
}

graphics_paint_rect_general :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, scale: [2]f32, angle: f32, pivot: [2]f32)
{
    graphics.batch_rect_general(self, rect, color, scale, angle, pivot)
}
