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
    zoom  := f32(1)
    angle := f32(0)

    if glfw.GetKey(WINDOW, glfw.KEY_LEFT)  == glfw.PRESS { angle += 5 }
    if glfw.GetKey(WINDOW, glfw.KEY_RIGHT) == glfw.PRESS { angle -= 5 }

    if glfw.GetKey(WINDOW, glfw.KEY_UP)   == glfw.PRESS { zoom += 0.01 }
    if glfw.GetKey(WINDOW, glfw.KEY_DOWN) == glfw.PRESS { zoom -= 0.01 }

    if glfw.GetKey(WINDOW, glfw.KEY_W) == glfw.PRESS { top  += 500 }
    if glfw.GetKey(WINDOW, glfw.KEY_A) == glfw.PRESS { left -= 500 }
    if glfw.GetKey(WINDOW, glfw.KEY_S) == glfw.PRESS { top  -= 500 }
    if glfw.GetKey(WINDOW, glfw.KEY_D) == glfw.PRESS { left += 500 }

    self.view.viewport.z = int(width)
    self.view.viewport.w = int(height)

    self.view.point.x += left * delta_time
    self.view.point.y += top * delta_time

    self.view.scale *= zoom

    self.view.angle += angle * delta_time

    self.time += delta_time
}

import "core:log"
import "core:math"

main_layer_update :: proc(self: ^Main_Layer, app: ^pax.App_State, frame_time: f32)
{
    glfw.PollEvents()
    glfw.SwapInterval(0)

    pax.graphics_set_clear_color({0.1, 0.1, 0.1})
    pax.graphics_set_multi_sampling(true)
    pax.graphics_set_blending(true)

    pax.graphics_begin(&app.graphics, &self.view)

    size_x  := 23
    size_y  := 32
    count_x := 64
    count_y := 64

    glyph := [4]int {0, -size_y * 9, size_x, size_y}
    color := [4]f32 {1, 1, 1, 1}

    sine := math.sin(self.time) / 2 + 0.5

    height := f32(9.0) + sine * 5
    ratio  := height / f32(size_y)

    for row in 0 ..< count_y {
        for col in 0 ..< count_x {
            rect := [4]f32 {
                f32(size_x * (col - count_x / 2)),
                f32(size_y * (row - count_y / 2)),
                f32(size_x) * ratio,
                f32(height),
            }

            rect.xy *= ratio 

            pax.graphics_paint_glyph(&app.graphics, rect,
                &TEXTURE_CONSOLA, glyph, color)
        }
    }

    pax.graphics_end(&app.graphics)

    glfw.SwapBuffers(WINDOW)

    log.debugf("%v", frame_time)
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
