package demo

import glfw "vendor:glfw"

import pax "../pax2d"
import gfx "../pax2d/graphics"

Main_Layer :: struct
{
    // empty...

    view: gfx.View,

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
    zoom  := f32(1)
    angle := f32(0)

    if glfw.GetKey(WINDOW, glfw.KEY_LEFT)  == glfw.PRESS { angle -= 5 }
    if glfw.GetKey(WINDOW, glfw.KEY_RIGHT) == glfw.PRESS { angle += 5 }

    if glfw.GetKey(WINDOW, glfw.KEY_UP)   == glfw.PRESS { zoom += 0.01 }
    if glfw.GetKey(WINDOW, glfw.KEY_DOWN) == glfw.PRESS { zoom -= 0.01 }

    if glfw.GetKey(WINDOW, glfw.KEY_W) == glfw.PRESS { top  -= 500 }
    if glfw.GetKey(WINDOW, glfw.KEY_A) == glfw.PRESS { left -= 500 }
    if glfw.GetKey(WINDOW, glfw.KEY_S) == glfw.PRESS { top  += 500 }
    if glfw.GetKey(WINDOW, glfw.KEY_D) == glfw.PRESS { left += 500 }

    self.view.viewport.z = int(width)
    self.view.viewport.w = int(height)

    self.view.point.x += left * delta_time
    self.view.point.y += top * delta_time

    self.view.scale *= zoom

    self.view.angle += angle * delta_time

    self.time += delta_time
}

main_layer_update :: proc(self: ^Main_Layer, app: ^pax.App_State, frame_time: f32)
{
    glfw.PollEvents()
    glfw.SwapInterval(0)

    gfx.set_clear_color({0.05, 0.05, 0.05})
    gfx.set_multi_sampling(true)
    gfx.set_blending(.BLENDING_ALPHA_VS_1_MINUS_ALPHA)

    count_x := 64
    count_y := 64

    color := [4]f32 {1, 1, 1, 1}

    gfx.begin(app)
    gfx.paint_rect_rotated(app, {-0.5, -0.5, 1, 1}, {1, 0, 0, 1}, self.time)
    gfx.end(app)

    glfw.SwapBuffers(WINDOW)
}

main_app_layer :: proc(self: ^Main_Layer) -> pax.App_Layer
{
    value := pax.app_layer_default()

    self.view.scale = {0.002, 0.002}

    value.self = auto_cast self

    value.proc_tick   = auto_cast main_layer_tick
    value.proc_update = auto_cast main_layer_update

    return value
}
