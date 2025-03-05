package pax2d

import graphics "./graphics"

//
// Types
//

Graphics_State :: graphics.State
View           :: graphics.View

//
// Procs
//

graphics_start :: proc() -> Graphics_State
{
    return graphics.start()
}

graphics_stop :: proc(self: ^Graphics_State)
{
    graphics.stop(self)
}

graphics_set_background_color :: proc(self: ^Graphics_State, color: [3]f32)
{
    graphics.set_background_color(self, color)
}

graphics_set_viewport :: proc(self: ^Graphics_State, rect: [4]int)
{
    graphics.set_viewport(self, rect)
}

graphics_begin :: proc(self: ^Graphics_State, view: ^View)
{
    graphics.begin(self, view)
}

graphics_end :: proc(self: ^Graphics_State)
{
    graphics.end(self)
}

graphics_paint_rect :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, scale: [2]f32 = {1, 1})
{
    graphics.paint_rect(self, rect, color, scale)
}

graphics_paint_rect_rotated :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32 = {0.5, 0.5})
{
    graphics.paint_rect_rotated(self, rect, color, angle, pivot)
}

graphics_paint_rect_general :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, scale: [2]f32, angle: f32, pivot: [2]f32)
{
    graphics.paint_rect_general(self, rect, color, scale, angle, pivot)
}
