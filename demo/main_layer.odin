package demo

import "core:log"

import glfw "vendor:glfw"

import pax "../pax2d"

Main_Layer :: struct
{
    // empty...
}

main_layer_enter :: proc(self: ^Main_Layer, app: ^pax.App_Info)
{
    // empty...
}

main_layer_update :: proc(self: ^Main_Layer, app: ^pax.App_Info, frame_time: f32)
{
    glfw.PollEvents()

    if glfw.WindowShouldClose(WINDOW) {
        app.active = false
    }

    if glfw.GetKey(WINDOW, glfw.KEY_ESCAPE) == glfw.PRESS {
        app.active = false
    }
    
    pax.graphics_begin(&app.graphics)

    pax.graphics_paint_rect(&app.graphics, {   0,    0, 0.5, 0.5}, {0.5, 0, 0, 0.5})
    pax.graphics_paint_rect(&app.graphics, {-0.5, -0.5, 0.5, 0.5}, {0, 0, 0.5, 0.5})

    pax.graphics_end(&app.graphics)

    glfw.SwapBuffers(WINDOW)
}

main_app_layer :: proc(self: ^Main_Layer) -> pax.App_Layer
{
    value := pax.app_layer_default()

    value.self = auto_cast self

    value.proc_update = auto_cast main_layer_update

    return value
}
