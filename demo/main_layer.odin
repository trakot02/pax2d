package demo

import "core:log"

import glfw "vendor:glfw"

import pax "../pax2d"

Main_Layer :: struct
{
    // empty...

    view: pax.View,

    mean_time: f32,
    total_time: f32,
}

main_layer_enter :: proc(self: ^Main_Layer, app: ^pax.App_State)
{
    self.view.viewport = {0, 0, 640, 640}
}

main_layer_tick :: proc(self: ^Main_Layer, app: ^pax.App_State, delta_time: f32)
{
    /*
    self.mean_time = self.mean_time * 0.9 + delta_time * 0.1
    self.total_time += delta_time

    log.debugf("mean_frame_time = %.9v, mean_frame_rate = %.9v", self.mean_time, 1.0 / self.mean_time)
    */
}

main_layer_update :: proc(self: ^Main_Layer, app: ^pax.App_State, frame_time: f32)
{
    glfw.PollEvents()
    // glfw.SwapInterval(0)

    width, height := glfw.GetWindowSize(WINDOW)

    self.view.viewport.zw = {
        int(width), int(height)
    }

    if glfw.WindowShouldClose(WINDOW) {
        app.active = false
    }

    if glfw.GetKey(WINDOW, glfw.KEY_ESCAPE) == glfw.PRESS {
        app.active = false
    }

    pax.graphics_begin(&app.graphics, &self.view)

    pax.graphics_paint_rect(&app.graphics, {0, 0, 0.5, 0.5}, {1, 0, 0, 0}, {1, 1.5})
    pax.graphics_paint_rect_rotated(&app.graphics, {-0.5, 0, 0.5, 0.5}, {0, 1, 0, 0}, self.total_time * 5, {})
    pax.graphics_paint_rect_general(&app.graphics, {-0.5, -0.5, 0.5, 0.5}, {0, 0, 1, 0}, {1.5, 0.5}, self.total_time, {})
    pax.graphics_paint_rect_general(&app.graphics, {-0.5, -0.5, 0.5, 0.5}, {1, 0, 1, 0}, {0.5, 1.5}, self.total_time, {})

    pax.graphics_end(&app.graphics)

    glfw.SwapBuffers(WINDOW)

    self.mean_time = self.mean_time * 0.9 + frame_time * 0.1
    self.total_time += frame_time

    log.debugf("mean_frame_time = %.9v, mean_frame_rate = %.9v", self.mean_time, 1.0 / self.mean_time)
}

main_app_layer :: proc(self: ^Main_Layer) -> pax.App_Layer
{
    value := pax.app_layer_default()

    value.self = auto_cast self

    value.proc_enter  = auto_cast main_layer_enter
    value.proc_tick   = auto_cast main_layer_tick
    value.proc_update = auto_cast main_layer_update

    return value
}
