package demo

import "core:log"

import glfw "vendor:glfw"
import gl   "vendor:OpenGL"

import pax "../pax2d"
import gfx "../pax2d/graphics"

WINDOW := glfw.WindowHandle {}

TEXTURE_GRASS := gfx.Texture {}

demo_start :: proc()
{
    glfw.Init()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    glfw.WindowHint(glfw.SAMPLES, 16)

    WINDOW = glfw.CreateWindow(640, 360, "Pax", nil, nil)

    glfw.MakeContextCurrent(WINDOW)

    gl.load_up_to(3, 3, glfw.gl_set_proc_address)
}

demo_stop :: proc()
{
    glfw.Terminate()
}

main :: proc()
{
    context.logger = log.create_console_logger()

    demo_start()

    defer demo_stop()

    app, state := pax.app_make()

    if state == false { return }

    defer pax.app_destroy(&app)

    // TEXTURE_GRASS, _ = gfx.texture_make_from_file("data/grass.png")

    main_layer := Main_Layer {}

    pax.app_loop(&app, main_app_layer(&main_layer), {
        frames_per_second = 64,
        frames_max_skip   = 64,
    })
}
