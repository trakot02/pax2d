package opengl

import gl "vendor:OpenGL"

//
// Values
//

VERTEX_ARRAY_DEFAULT := vertex_array_make_default()

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

@(private)
vertex_array_make_default :: proc() -> Vertex_Array
{
    value, state := vertex_array_make()

    if state == true {
        vertex_array_bind(&value)
    }

    return value
}

clear :: proc(color: [4]f32 = {})
{
    gl.ClearColor(color.r, color.g, color.b, color.a)

    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

paint :: proc(shader: ^Shader, buffer: ^Vertex_Buffer, textures: ^Texture_Bundle, samplers: ^Sampler_Bundle)
{
    shader_bind(shader)

    texture_bundle_bind(textures)
    sampler_bundle_bind(samplers)

    vertex_buffer_bind(buffer)

    gl.DrawArrays(gl.TRIANGLES, 0, i32(buffer.items))

    vertex_buffer_unbind()

    sampler_bundle_unbind()
    texture_bundle_unbind()

    shader_unbind()
}
