package opengl

import "core:log"
import "core:strings"
import "core:mem"

import gl "vendor:OpenGL"

//
// Values
//

SHADER_STAGE_MAX :: int(2)

//
// Types
//

Shader_Stage :: enum
{
    STAGE_NONE,
    STAGE_VERTEX,
    STAGE_PIXEL,
}

Shader_Builder :: struct
{
    array: [SHADER_STAGE_MAX]int,
    items: int,
}

Shader :: struct
{
    handle: int,
}

//
// Procs
//

shader_builder_clear :: proc(self: ^Shader_Builder)
{
    for i in 0 ..< self.items {
        gl.DeleteShader(u32(self.array[i]))
    }

    self.items = 0
}

shader_builder_add_stage :: proc(self: ^Shader_Builder, stage: Shader_Stage, source: string) -> bool
{
    index := self.items

    if index < 0 || index >= len(self.array) {
        return false
    }

    stage_value := SHADER_STAGE[stage]

    if stage == .STAGE_NONE { return false }

    handle := gl.CreateShader(u32(stage_value))

    if handle == 0 { return false }

    if compile_shader_stage(int(handle), source) {
        self.items        += 1
        self.array[index]  = int(handle)

        return true
    }

    return false
}

shader_build :: proc(self: ^Shader_Builder, shader: ^Shader) -> bool
{
    state := true

    for i in 0 ..< self.items {
        gl.AttachShader(u32(shader.handle), u32(self.array[i]))
    }

    if link_shader(shader.handle) == false {
        for i in 0 ..< self.items {
            gl.DetachShader(u32(shader.handle), u32(self.array[i]))
        }

        state = false
    }

    return state
}

shader_make :: proc() -> (Shader, bool)
{
    handle := gl.CreateProgram()
    value  := Shader {}

    if handle != 0 {
        value.handle = int(handle)
    }

    return value, handle != 0
}

shader_make_from_builder :: proc(builder: ^Shader_Builder) -> (Shader, bool)
{
    value, state := shader_make()

    if state == false { return value, state }

    state = shader_build(builder, &value)

    if state == false {
        shader_destroy(&value)
    }

    return value, state
}

shader_destroy :: proc(self: ^Shader)
{
    handle := u32(self.handle)

    self.handle = 0

    gl.DeleteProgram(handle)
}

shader_find_uniform :: proc(self: ^Shader, name: string) -> (int, bool)
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone uniform name to c-string")

        return 0, false
    }

    defer mem.free_all(context.temp_allocator)

    uniform := gl.GetUniformLocation(u32(self.handle), clone)

    if uniform != -1 {
        return int(uniform), true
    }

    return 0, false
}

shader_execute :: proc(self: ^Shader, mesh: ^Mesh)
{
    vertices := mesh.vertices.items
    indices  := mesh.indices.items

    gl.BindVertexArray(u32(mesh.spec.handle))

    gl.UseProgram(u32(self.handle))

    // bind and write uniforms

    defer gl.BindVertexArray(0)
    defer gl.UseProgram(0)

    switch indices != 0 {
        case true:
            gl.DrawElements(gl.TRIANGLES, i32(indices),
                gl.UNSIGNED_INT, nil)

        case false:
            gl.DrawArrays(gl.TRIANGLES, 0, i32(vertices))
    }
}

@(private)
compile_shader_stage :: proc(handle: int, source: string) -> bool
{
    buffer := [1024]byte {}
    state  := i32 {}

    clone, error := strings.clone_to_cstring(source,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone shader stage source to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    gl.ShaderSource(u32(handle), 1, &clone, nil)
    gl.CompileShader(u32(handle))

    gl.GetShaderiv(u32(handle), gl.COMPILE_STATUS, &state)

    if state == 0 {
        gl.GetShaderInfoLog(u32(handle), len(buffer), nil, &buffer[0])

        log.errorf("Shader: %v, Unable to compile shader stage",
            cstring(&buffer[0]))
    }

    return state != 0
}

@(private)
link_shader :: proc(handle: int) -> bool
{
    buffer := [1024]byte {}
    state  := i32 {}

    gl.LinkProgram(u32(handle))

    gl.GetProgramiv(u32(handle), gl.LINK_STATUS, &state)

    if state == 0 {
        gl.GetProgramInfoLog(u32(handle), len(buffer), nil, &buffer[0])

        log.errorf("Shader: %v, Unable to link shader",
            cstring(&buffer[0]))
    }

    return state != 0

}

@(private)
SHADER_STAGE := [Shader_Stage]int {
    .STAGE_NONE   = 0,
    .STAGE_VERTEX = gl.VERTEX_SHADER,
    .STAGE_PIXEL  = gl.FRAGMENT_SHADER,
}
