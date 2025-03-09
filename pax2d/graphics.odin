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

graphics_set_clear_color :: proc(color: [3]f32)
{
    graphics.set_clear_color(color)
}

graphics_set_multi_sampling :: proc(state: bool)
{
    graphics.set_multi_sampling(state)
}

graphics_set_blending :: proc(state: bool)
{
    graphics.set_blending(state)
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

graphics_paint_rect_rotated :: proc(self: ^Graphics_State, rect: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32 = {}, scale: [2]f32 = {1, 1})
{
    graphics.paint_rect_rotated(self, rect, color, angle, pivot, scale)
}

graphics_paint_sprite :: proc(self: ^Graphics_State, rect: [4]f32, texture: ^Texture, sprite: [4]int, color: [4]f32, scale: [2]f32 = {1, 1})
{
    graphics.paint_sprite(self, rect, texture, sprite, color, scale)
}

graphics_paint_sprite_rotated :: proc(self: ^Graphics_State, rect: [4]f32, texture: ^Texture, sprite: [4]int, color: [4]f32, angle: f32, pivot: [2]f32 = {}, scale: [2]f32 = {1, 1})
{
    graphics.paint_sprite_rotated(self, rect, texture, sprite, color, angle, pivot, scale)
}

graphics_paint_glyph :: proc(self: ^Graphics_State, rect: [4]f32, texture: ^Texture, glyph: [4]int, color: [4]f32, scale: [2]f32 = {1, 1})
{
    graphics.paint_glyph(self, rect, texture, glyph, color, scale)
}

graphics_paint_glyph_rotated :: proc(self: ^Graphics_State, rect: [4]f32, texture: ^Texture, glyph: [4]int, color: [4]f32, angle: f32, pivot: [2]f32 = {}, scale: [2]f32 = {1, 1})
{
    graphics.paint_glyph_rotated(self, rect, texture, glyph, color, angle, pivot, scale)
}
