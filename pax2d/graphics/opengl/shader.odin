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

Shader_Stage_Type :: enum
{
    STAGE_NONE,
    STAGE_VERTEX,
    STAGE_PIXEL,
}

Shader_Value_Type :: enum
{
    TYPE_NONE,
    TYPE_F32,
    TYPE_F32_VEC2,
    TYPE_F32_VEC3,
    TYPE_F32_VEC4,
    TYPE_F32_MAT4,
}

Shader :: struct
{
    handle: int,
}

Shader_Builder_Array :: [SHADER_STAGE_MAX]int

Shader_Builder :: struct
{
    array: Shader_Builder_Array,
    items: int,
}

//
// Procs
//

shader_add_stage_from_source :: proc(self: ^Shader_Builder, type: Shader_Stage_Type, source: string) -> bool
{
    type_value := SHADER_STAGE_TYPE[type]

    if type == .STAGE_NONE { return false }

    handle := gl.CreateShader(u32(type_value))

    if handle == 0 { return false }

    if shader_compile_stage(self, int(handle), source) {
        return shader_add_stage(self, int(handle))
    }

    return false
}

shader_add_stage_from_file :: proc(self: ^Shader_Builder, type: Shader_Stage_Type, filename: string) -> bool
{
    assert(false, "Not implemented yet")

    return false
}

shader_build :: proc(self: ^Shader_Builder, shader: ^Shader) -> bool
{
    for i in 0 ..< self.items {
        gl.AttachShader(u32(shader.handle), u32(self.array[i]))
    }

    gl.LinkProgram(u32(shader.handle))

    state := shader_test_link_error(self, shader.handle)

    if state == false {
        for i in 0 ..< self.items {
            gl.DetachShader(u32(shader.handle), u32(self.array[i]))
        }
    }

    for i in 0 ..< self.items {
        gl.DeleteShader(u32(self.array[i]))
    }

    self.items = 0

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

        return {}, false
    }

    return value, true
}

shader_destroy :: proc(self: ^Shader)
{
    handle := u32(self.handle)

    self.handle = 0

    gl.DeleteProgram(handle)
}

shader_bind :: proc(self: ^Shader)
{
    gl.UseProgram(u32(self.handle))
}

shader_unbind :: proc()
{
    gl.UseProgram(0)
}

@(private)
shader_add_stage :: proc(self: ^Shader_Builder, handle: int) -> bool
{
    index := self.items

    if index >= 0 && index < SHADER_STAGE_MAX {
        self.items        += 1
        self.array[index]  = handle

        return true
    }

    return false
}

@(private)
shader_compile_stage :: proc(self: ^Shader_Builder, handle: int, source: string) -> bool
{
    clone, error := strings.clone_to_cstring(source,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader_Builder: Unable to clone shader stage source to c-string")

        return false
    }

    defer mem.free_all(context.temp_allocator)

    gl.ShaderSource(u32(handle), 1, &clone, nil)
    gl.CompileShader(u32(handle))

    return shader_test_compile_error(self, handle)
}

@(private)
shader_test_compile_error :: proc(self: ^Shader_Builder, handle: int) -> bool
{
    bytes := [1024]byte {}
    state := i32 {}

    gl.GetShaderiv(u32(handle), gl.COMPILE_STATUS, &state)

    if state == 0 {
        gl.GetShaderInfoLog(u32(handle), len(bytes), nil, &bytes[0])

        log.errorf("Shader_Builder: Unable to compile shader stage, %v", cstring(&bytes[0]))
    }

    return state != 0
}

@(private)
shader_test_link_error :: proc(self: ^Shader_Builder, handle: int) -> bool
{
    bytes := [1024]byte {}
    state := i32 {}

    gl.GetProgramiv(u32(handle), gl.LINK_STATUS, &state)

    if state == 0 {
        gl.GetProgramInfoLog(u32(handle), len(bytes), nil, &bytes[0])

        log.errorf("Shader_Builder: Unable to link shader, %v", cstring(&bytes[0]))
    }

    return state != 0
}

@(private)
SHADER_STAGE_TYPE := [Shader_Stage_Type]int {
    .STAGE_NONE   = 0,
    .STAGE_VERTEX = gl.VERTEX_SHADER,
    .STAGE_PIXEL  = gl.FRAGMENT_SHADER,
}

@(private)
SHADER_VALUE_TYPE_CLASS := [Shader_Value_Type]int {
    .TYPE_NONE     = 0,
    .TYPE_F32      = gl.FLOAT,
    .TYPE_F32_VEC2 = gl.FLOAT,
    .TYPE_F32_VEC3 = gl.FLOAT,
    .TYPE_F32_VEC4 = gl.FLOAT,
    .TYPE_F32_MAT4 = gl.FLOAT,
}

@(private)
SHADER_VALUE_TYPE_ITEMS := [Shader_Value_Type]int {
    .TYPE_NONE     = 0,
    .TYPE_F32      = 1,
    .TYPE_F32_VEC2 = 2,
    .TYPE_F32_VEC3 = 3,
    .TYPE_F32_VEC4 = 4,
    .TYPE_F32_MAT4 = 16,
}

@(private)
SHADER_VALUE_TYPE_BYTES := [Shader_Value_Type]int {
    .TYPE_NONE     = 0,
    .TYPE_F32      = size_of(f32) * 1,
    .TYPE_F32_VEC2 = size_of(f32) * 2,
    .TYPE_F32_VEC3 = size_of(f32) * 3,
    .TYPE_F32_VEC4 = size_of(f32) * 4,
    .TYPE_F32_MAT4 = size_of(f32) * 16,
}
