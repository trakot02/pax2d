package demo

import glfw "vendor:glfw"

import pax "../pax2d"

Main_Layer :: struct
{
    // empty...

    view: pax.View,

    time: f32,
}

main_layer_tick :: proc(self: ^Main_Layer, app: ^pax.App_State, delta_time: f32)
{
    if glfw.GetKey(WINDOW, glfw.KEY_ESCAPE) == glfw.PRESS {
        app.active = false
    }

    if glfw.WindowShouldClose(WINDOW) { app.active = false }

    width, height := glfw.GetWindowSize(WINDOW)

    left  := f32(0)
    top   := f32(0)
    zoom  := f32(0)
    angle := f32(0)

    if glfw.GetKey(WINDOW, glfw.KEY_LEFT)  == glfw.PRESS { angle += 5 }
    if glfw.GetKey(WINDOW, glfw.KEY_RIGHT) == glfw.PRESS { angle -= 5 }

    if glfw.GetKey(WINDOW, glfw.KEY_UP)   == glfw.PRESS { zoom += 0.05 }
    if glfw.GetKey(WINDOW, glfw.KEY_DOWN) == glfw.PRESS { zoom -= 0.05 }

    if glfw.GetKey(WINDOW, glfw.KEY_W) == glfw.PRESS { top  += 50 }
    if glfw.GetKey(WINDOW, glfw.KEY_A) == glfw.PRESS { left -= 50 }
    if glfw.GetKey(WINDOW, glfw.KEY_S) == glfw.PRESS { top  -= 50 }
    if glfw.GetKey(WINDOW, glfw.KEY_D) == glfw.PRESS { left += 50 }

    self.view.viewport.z = int(width)
    self.view.viewport.w = int(height)

    self.view.point.x += left * delta_time
    self.view.point.y += top * delta_time

    self.view.scale += zoom / 2 * delta_time

    if self.view.scale.x < 0 || self.view.scale.y < 0 {
        self.view.scale = {}
    }

    self.view.angle += angle * delta_time

    self.time += delta_time
}

main_layer_update :: proc(self: ^Main_Layer, app: ^pax.App_State, frame_time: f32)
{
    glfw.PollEvents()

    pax.graphics_begin(&app.graphics, &self.view)

    pax.graphics_paint_rect(&app.graphics, {-24, -24, 16, 16}, {0.3, 0.3, 0.3, 1})
    pax.graphics_paint_rect(&app.graphics, {-24,   8, 16, 16}, {0.3, 0.3, 0.3, 1})
    pax.graphics_paint_rect(&app.graphics, {  8, -24, 16, 16}, {0.3, 0.3, 0.3, 1})
    pax.graphics_paint_rect(&app.graphics, {  8,   8, 16, 16}, {0.3, 0.3, 0.3, 1})

    pax.graphics_paint_rect_rotated(&app.graphics, {-24, -24, 16, 16},
        {1, 0, 0, 1}, {1.5, 0.5}, self.time)

    pax.graphics_paint_rect_rotated(&app.graphics, {-24, 8, 16, 16},
        {0, 1, 0, 1}, {0.5, 1.5}, self.time)

    pax.graphics_paint_rect_rotated(&app.graphics, {8, -24, 16, 16},
        {0, 0, 1, 1}, {1.5, 0.5}, self.time)

    pax.graphics_paint_rect_rotated(&app.graphics, {8, 8, 16, 16},
        {1, 1, 1, 1}, {0.5, 1.5}, self.time)

    pax.graphics_paint_sprite_rotated(&app.graphics, &TEXTURE, {0, 0, 16, 32}, {1, 1, 1, 1}, {-8, 32},
        {-1, 1}, 0)

    pax.graphics_paint_sprite_rotated(&app.graphics, &TEXTURE, {0, 0, 16, 32}, {1, 1, 1, 1}, {18, 32},
        {1, 1}, 0)

    pax.graphics_end(&app.graphics)

    glfw.SwapBuffers(WINDOW)
}

main_app_layer :: proc(self: ^Main_Layer) -> pax.App_Layer
{
    value := pax.app_layer_default()

    self.view.scale = {0.05, 0.05}

    value.self = auto_cast self

    value.proc_tick   = auto_cast main_layer_tick
    value.proc_update = auto_cast main_layer_update

    return value
}
