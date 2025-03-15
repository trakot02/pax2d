package opengl

import gl "vendor:OpenGL"

//
// Types
//

Blending :: enum
{
    BLENDING_NONE,
    BLENDING_ALPHA_VS_1_MINUS_ALPHA,
    BLENDING_1_MINUS_ALPHA_VS_ALPHA,
}

//
// Procs
//

set_clear_color :: proc(color: [3]f32 = {})
{
    red   := f32(color.r)
    green := f32(color.g)
    blue  := f32(color.b)

    gl.ClearColor(red, green, blue, 1)
}

set_multi_sampling :: proc(value: bool)
{
    switch value {
        case false: gl.Disable(gl.MULTISAMPLE)
        case true:  gl.Enable(gl.MULTISAMPLE)
    }
}

set_depth_testing :: proc(value: bool)
{
    switch value {
        case false: gl.Disable(gl.DEPTH_TEST)
        case true:  gl.Enable(gl.DEPTH_TEST)
    }
}

set_blending :: proc(value: Blending)
{
    #partial switch value {
        case .BLENDING_NONE:
            gl.Disable(gl.BLEND)

        case: gl.Enable(gl.BLEND)
    }

    #partial switch value {
        case .BLENDING_ALPHA_VS_1_MINUS_ALPHA:
            gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

        case .BLENDING_1_MINUS_ALPHA_VS_ALPHA:
            gl.BlendFunc(gl.ONE_MINUS_SRC_ALPHA, gl.SRC_ALPHA)
    }
}

set_viewport :: proc(viewport: [4]int)
{
    left   := i32(viewport.x)
    top    := i32(viewport.y)
    width  := i32(viewport.z)
    height := i32(viewport.w)

    gl.Viewport(left, top, width, height)
}

clear_buffer_color :: proc()
{
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

clear_buffer_depth :: proc()
{
    gl.Clear(gl.DEPTH_BUFFER_BIT)
}

clear_buffer_any :: proc()
{
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}
