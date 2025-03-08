package pax2d

import graphics "./graphics"

//
// Types
//

Vertex_Buffer :: graphics.Vertex_Buffer
Index_Buffer  :: graphics.Index_Buffer

Shader :: graphics.Shader

Sampler :: graphics.Sampler
Texture :: graphics.Texture

Graphics_State :: graphics.State
View           :: graphics.View

//
// Procs
//

graphics_texture_make_from_file :: proc(filename: string) -> (Texture, bool)
{
    return graphics.texture_make_from_file(filename)
}

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

graphics_paint_rect_rotated :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, scale: [2]f32, angle: f32, pivot: [2]f32 = {})
{
    graphics.paint_rect_rotated(self, rect, color, scale, angle, pivot)
}

graphics_paint_sprite :: proc(self: ^Graphics_State, texture: ^Texture, sprite: [4]int, color: [4]f32, point: [2]f32, scale: [2]f32 = {1, 1})
{
    graphics.paint_sprite(self, texture, sprite, color, point, scale)
}

graphics_paint_sprite_rotated :: proc(self: ^Graphics_State, texture: ^Texture, sprite: [4]int, color: [4]f32, point: [2]f32, scale: [2]f32, angle: f32, pivot: [2]f32 = {})
{
    graphics.paint_sprite_rotated(self, texture, sprite, color, point, scale, angle, pivot)
}
