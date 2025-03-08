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
    TYPE_I32_ARRAY,
    TYPE_I32,
    TYPE_I32_VEC2,
    TYPE_I32_VEC3,
    TYPE_I32_VEC4,
    TYPE_F32_ARRAY,
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

shader_bind :: proc(self: ^Shader)
{
    gl.UseProgram(u32(self.handle))
}

shader_unbind :: proc()
{
    gl.UseProgram(0)
}

shader_get_argument :: proc(self: ^Shader, name: string) -> (int, bool)
{
    clone, error := strings.clone_to_cstring(name,
        context.temp_allocator)

    if error != nil {
        log.errorf("Shader: Unable to clone argument name to c-string")

        return 0, false
    }

    defer mem.free_all(context.temp_allocator)

    argument := gl.GetUniformLocation(u32(self.handle), clone)

    if argument != -1 {
        return int(argument), true
    }

    return 0, false
}

shader_write_i32_array :: proc(self: ^Shader, name: string, value: []i32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        other := value
        items := len(value)

        gl.Uniform1iv(i32(argument), i32(items),
            &other[0])
    }

    return state
}

shader_write_i32 :: proc(self: ^Shader, name: string, value: i32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        gl.Uniform1i(i32(argument), value)
    }

    return state
}

shader_write_i32_vec2 :: proc(self: ^Shader, name: string, value: [2]i32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        gl.Uniform2i(i32(argument), value.x, value.y)
    }

    return state
}

shader_write_i32_vec3 :: proc(self: ^Shader, name: string, value: [3]i32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        gl.Uniform3i(i32(argument), value.x, value.y, value.z)
    }

    return state
}

shader_write_i32_vec4 :: proc(self: ^Shader, name: string, value: [4]i32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        gl.Uniform4i(i32(argument), value.x, value.y, value.z, value.w)
    }

    return state
}

shader_write_f32_array :: proc(self: ^Shader, name: string, value: []f32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        other := value
        items := len(value)

        gl.Uniform1fv(i32(argument), i32(items),
            &other[0])
    }

    return state
}

shader_write_f32 :: proc(self: ^Shader, name: string, value: f32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        gl.Uniform1f(i32(argument), value)
    }

    return state
}

shader_write_f32_vec2 :: proc(self: ^Shader, name: string, value: [2]f32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        gl.Uniform2f(i32(argument), value.x, value.y)
    }

    return state
}

shader_write_f32_vec3 :: proc(self: ^Shader, name: string, value: [3]f32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        gl.Uniform3f(i32(argument), value.x, value.y, value.z)
    }

    return state
}

shader_write_f32_vec4 :: proc(self: ^Shader, name: string, value: [4]f32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        gl.Uniform4f(i32(argument), value.x, value.y, value.z, value.w)
    }

    return state
}

shader_write_f32_mat4 :: proc(self: ^Shader, name: string, value: matrix[4, 4]f32) -> bool
{
    argument, state := shader_get_argument(self, name)

    if state == true {
        gl.UseProgram(u32(self.handle))

        defer gl.UseProgram(0)

        other := value

        gl.UniformMatrix4fv(i32(argument), 1, false,
            &other[0][0])
    }

    return state
}

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
    .TYPE_NONE      = 0,
    .TYPE_I32_ARRAY = gl.INT,
    .TYPE_I32       = gl.INT,
    .TYPE_I32_VEC2  = gl.INT,
    .TYPE_I32_VEC3  = gl.INT,
    .TYPE_I32_VEC4  = gl.INT,
    .TYPE_F32_ARRAY = gl.FLOAT,
    .TYPE_F32       = gl.FLOAT,
    .TYPE_F32_VEC2  = gl.FLOAT,
    .TYPE_F32_VEC3  = gl.FLOAT,
    .TYPE_F32_VEC4  = gl.FLOAT,
    .TYPE_F32_MAT4  = gl.FLOAT,
}

@(private)
SHADER_VALUE_TYPE_ITEMS := [Shader_Value_Type]int {
    .TYPE_NONE      = 0,
    .TYPE_I32_ARRAY = 0,
    .TYPE_I32       = 1,
    .TYPE_I32_VEC2  = 2,
    .TYPE_I32_VEC3  = 3,
    .TYPE_I32_VEC4  = 4,
    .TYPE_F32_ARRAY = 0,
    .TYPE_F32       = 1,
    .TYPE_F32_VEC2  = 2,
    .TYPE_F32_VEC3  = 3,
    .TYPE_F32_VEC4  = 4,
    .TYPE_F32_MAT4  = 16,
}

@(private)
SHADER_VALUE_TYPE_BYTES := [Shader_Value_Type]int {
    .TYPE_NONE      = 0,
    .TYPE_I32_ARRAY = 0,
    .TYPE_I32       = size_of(i32) * 1,
    .TYPE_I32_VEC2  = size_of(i32) * 2,
    .TYPE_I32_VEC3  = size_of(i32) * 3,
    .TYPE_I32_VEC4  = size_of(i32) * 4,
    .TYPE_F32_ARRAY = 0,
    .TYPE_F32       = size_of(f32) * 1,
    .TYPE_F32_VEC2  = size_of(f32) * 2,
    .TYPE_F32_VEC3  = size_of(f32) * 3,
    .TYPE_F32_VEC4  = size_of(f32) * 4,
    .TYPE_F32_MAT4  = size_of(f32) * 16,
}
