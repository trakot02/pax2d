package pax2d

import graphics "./graphics"

//
// Types
//

Graphics_State :: graphics.State

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

graphics_begin :: proc(self: ^Graphics_State)
{
    // TODO(gio): prepares the scene
}

graphics_end :: proc(self: ^Graphics_State)
{
    // TODO(gio): clears and flushes
}

graphics_paint_rect :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, scale: [2]f32 = {1, 1})
{
    // TODO(gio): pushes to the batch
}

graphics_paint_rect_rotated :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32 = {0.5, 0.5})
{
    // TODO(gio): pushes to the batch
}

graphics_paint_rect_general :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, scale: [2]f32, angle: f32, pivot: [2]f32)
{
    // TODO(gio): pushes to the batch
}
