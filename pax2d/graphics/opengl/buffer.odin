package opengl

import gl "vendor:OpenGL"

//
// Types
//

/*
Buffer_Usage :: enum
{
    USAGE_NONE,
    USAGE_DYNAMIC_WRITE,
}
*/

Vertex_Buffer :: struct
{
    handle: int,
    stride: int,
    length: int,
    items:  int,
}

Index_Buffer :: struct
{
    handle: int,
    stride: int,
    length: int,
    items:  int,
}

Uniform_Buffer :: struct
{
    handle: int,
    length: int,
    items:  int,
}

//
// Procs
//

vertex_buffer_make :: proc() -> (Vertex_Buffer, bool)
{
    handle := u32 {}
    value  := Vertex_Buffer {}

    gl.GenBuffers(1, &handle)

    if handle != 0 {
        value.handle = int(handle)
    }

    return value, handle != 0
}

vertex_buffer_alloc :: proc(limit: int, $T: typeid) -> (Vertex_Buffer, bool)
{
    value, state := vertex_buffer_make()

    if state == false { return value, state }

    state = vertex_buffer_realloc(&value, limit, T)

    if state == false {
        vertex_buffer_destroy(&value)
    }

    return value, state
}

vertex_buffer_destroy :: proc(self: ^Vertex_Buffer)
{
    handle := u32(self.handle)

    self.handle = 0
    self.stride = 0
    self.length = 0
    self.items  = 0

    gl.DeleteBuffers(1, &handle)
}

vertex_buffer_get_size :: proc(self: ^Vertex_Buffer) -> int
{
    return self.length / self.stride
}

vertex_buffer_clear :: proc(self: ^Vertex_Buffer)
{
    self.items = 0
}

vertex_buffer_realloc :: proc(self: ^Vertex_Buffer, limit: int, $T: typeid) -> bool
{
    stride := size_of(T)
    length := stride * limit

    gl.BindBuffer(gl.ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    gl.BufferData(gl.ARRAY_BUFFER, length, nil,
        gl.DYNAMIC_DRAW)

    self.stride = stride
    self.length = length

    return true
}

vertex_buffer_write_all :: proc(self: ^Vertex_Buffer, data: []$T) -> bool
{
    items  := len(data)
    stride := size_of(T)
    length := stride * items

    if self.stride != stride { return false }
    if self.length != length { return false }

    gl.BindBuffer(gl.ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    gl.BufferSubData(gl.ARRAY_BUFFER, 0, length, &data[0])

    self.items = items

    return true
}

vertex_buffer_write_to_front :: proc(self: ^Vertex_Buffer, data: []$T) -> bool
{
    items  := len(data)
    stride := size_of(T)
    length := stride * items

    if self.stride != stride { return false }
    if self.length  < length { return false }

    gl.BindBuffer(gl.ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    gl.BufferSubData(gl.ARRAY_BUFFER, 0, length, &data[0])

    self.items = items

    return true
}

index_buffer_make :: proc() -> (Index_Buffer, bool)
{
    handle := u32 {}
    value  := Index_Buffer {}

    gl.GenBuffers(1, &handle)

    if handle != 0 {
        value.handle = int(handle)
    }

    return value, handle != 0
}

index_buffer_alloc :: proc(limit: int, $T: typeid) -> (Index_Buffer, bool)
{
    value, state := index_buffer_make()

    if state == false { return value, state }

    state = index_buffer_realloc(&value, limit, T)

    if state == false {
        index_buffer_destroy(&value)
    }

    return value, state
}

index_buffer_destroy :: proc(self: ^Index_Buffer)
{
    handle := u32(self.handle)

    self.handle = 0
    self.stride = 0
    self.length = 0
    self.items  = 0

    gl.DeleteBuffers(1, &handle)
}

index_buffer_get_size :: proc(self: ^Index_Buffer) -> int
{
    return self.length / self.stride
}

index_buffer_clear :: proc(self: ^Index_Buffer)
{
    self.items = 0
}

index_buffer_realloc :: proc(self: ^Index_Buffer, limit: int, $T: typeid) -> bool
{
    stride := size_of(T)
    length := stride * limit

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)

    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, length, nil,
        gl.DYNAMIC_DRAW)

    self.stride = stride
    self.length = length

    return true
}

index_buffer_write_all :: proc(self: ^Index_Buffer, data: []$T) -> bool
{
    items  := len(data)
    stride := size_of(T)
    length := stride * items

    if self.stride != stride { return false }
    if self.length != length { return false }

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)

    gl.BufferSubData(gl.ELEMENT_ARRAY_BUFFER, 0, length, &data[0])

    self.items = items

    return true
}

index_buffer_write_to_front :: proc(self: ^Index_Buffer, data: []$T) -> bool
{
    items  := len(data)
    stride := size_of(T)
    length := stride * items

    if self.stride != stride { return false }
    if self.length  < length { return false }

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)

    gl.BufferSubData(gl.ELEMENT_ARRAY_BUFFER, 0, length, &data[0])

    self.items = items

    return true
}

uniform_buffer_make :: proc() -> (Uniform_Buffer, bool)
{
    handle := u32 {}
    value  := Uniform_Buffer {}

    gl.GenBuffers(1, &handle)

    if handle != 0 {
        value.handle = int(handle)
    }

    return value, handle != 0
}

uniform_buffer_alloc :: proc(length: int) -> (Uniform_Buffer, bool)
{
    value, state := uniform_buffer_make()

    if state == false { return value, state }

    state = uniform_buffer_realloc(&value, length)

    if state == false {
        uniform_buffer_destroy(&value)
    }

    return value, state
}

uniform_buffer_destroy :: proc(self: ^Uniform_Buffer)
{
    handle := u32(self.handle)

    self.handle = 0
    self.length = 0
    self.items  = 0
}

uniform_buffer_clear :: proc(self: ^Uniform_Buffer)
{
    self.items = 0
}

uniform_buffer_realloc :: proc(self: ^Uniform_Buffer, length: int) -> bool
{
    gl.BindBuffer(gl.UNIFORM_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.UNIFORM_BUFFER, 0)

    gl.BufferData(gl.UNIFORM_BUFFER, length, nil,
        gl.DYNAMIC_DRAW)

    self.length = length

    return true
}

uniform_buffer_write_all :: proc(self: ^Uniform_Buffer, data: []byte) -> bool
{
    length := len(data)

    if self.length != length { return false }

    gl.BindBuffer(gl.UNIFORM_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.UNIFORM_BUFFER, 0)

    gl.BufferSubData(gl.UNIFORM_BUFFER, 0, length, &data[0])

    self.items = length

    return true
}

uniform_buffer_write_to_front :: proc(self: ^Uniform_Buffer, data: []byte) -> bool
{
    length := len(data)

    if self.length < length { return false }

    gl.BindBuffer(gl.UNIFORM_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.UNIFORM_BUFFER, 0)

    gl.BufferSubData(gl.UNIFORM_BUFFER, 0, length, &data[0])

    self.items = length

    return true
}

/*
@(private)
BUFFER_USAGE := [Buffer_Usage]int {
    .USAGE_NONE          = 0,
    .USAGE_DYNAMIC_WRITE = gl.DYNAMIC_DRAW,
}
*/
