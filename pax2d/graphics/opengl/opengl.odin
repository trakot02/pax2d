package opengl

import gl "vendor:OpenGL"

//
// Types
//

Vertex_Array :: struct
{
    handle: int,
}

//
// Procs
//

vertex_array_make :: proc() -> (Vertex_Array, bool)
{
    handle := u32 {}
    value  := Vertex_Array {}

    gl.GenVertexArrays(1, &handle)

    if handle != 0 {
        value.handle = int(handle)
    }

    return value, handle != 0
}

vertex_array_destroy :: proc(self: ^Vertex_Array)
{
    handle := u32(self.handle)

    self.handle = 0

    gl.DeleteVertexArrays(1, &handle)
}

vertex_array_bind :: proc(self: ^Vertex_Array)
{
    gl.BindVertexArray(u32(self.handle))
}

vertex_array_unbind :: proc()
{
    gl.BindVertexArray(0)
}

set_viewport :: proc(rect: [4]int)
{
    gl.Viewport(i32(rect.x), i32(rect.y), i32(rect.z), i32(rect.w))
}

set_background_color :: proc(color: [3]f32 = {})
{
    gl.ClearColor(color.r, color.g, color.b, 1)
}

clear :: proc()
{
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

paint :: proc(buffer: ^Vertex_Buffer)
{
    //
    // NOTE(gio): Optional due to the vertex array.
    //

    /**
     * gl.BindBuffer(gl.ARRAY_BUFFER, u32(buffer.handle))
     *
     * defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
     *
     */

    gl.DrawArrays(gl.TRIANGLES, 0, i32(buffer.items))
}
