package opengl

import gl "vendor:OpenGL"

//
// Values
//

VERTEX_ATTRIB_MAX :: int(8)

//
// Types
//

Buffer_Usage :: enum
{
    USAGE_NONE,
    USAGE_DYNAMIC_READ,
}

Vertex_Buffer :: struct
{
    handle: int,
    stride: int,
    bytes:  int,
    items:  int,
}

Index_Buffer :: struct
{
    handle: int,
    stride: int,
    bytes:  int,
    items:  int,
}

Vertex_Layout_Array :: [VERTEX_ATTRIB_MAX]Shader_Value_Type

Vertex_Layout :: struct
{
    array: Vertex_Layout_Array,
    items: int,
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

vertex_buffer_make_with_storage :: proc(layout: Vertex_Layout, items: int) -> (Vertex_Buffer, bool)
{
    value, state := vertex_buffer_make()

    if state == false { return value, state }

    state = vertex_buffer_set_storage(&value, layout, items)

    if state == false {
        vertex_buffer_destroy(&value)

        return {}, false
    }

    return value, true
}

vertex_buffer_destroy :: proc(self: ^Vertex_Buffer)
{
    handle := u32(self.handle)

    self.handle = 0
    self.bytes  = 0
    self.items  = 0

    gl.DeleteBuffers(1, &handle)
}

vertex_buffer_bind :: proc(self: ^Vertex_Buffer)
{
    gl.BindBuffer(gl.ARRAY_BUFFER, u32(self.handle))
}

vertex_buffer_unbind :: proc()
{
    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
}

vertex_buffer_clear :: proc(self: ^Vertex_Buffer)
{
    self.items = 0
}

vertex_buffer_set_storage :: proc(self: ^Vertex_Buffer, layout: Vertex_Layout, items: int) -> bool
{
    stride := vertex_layout_get_stride(layout)
    bytes  := stride * items

    gl.BindBuffer(gl.ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    gl.BufferData(gl.ARRAY_BUFFER, bytes, nil,
        gl.DYNAMIC_DRAW)

    self.stride = stride
    self.bytes  = bytes

    vertex_buffer_set_layout(self, layout)

    return true
}

vertex_buffer_write_all :: proc(self: ^Vertex_Buffer, data: []$T) -> bool
{
    stride := size_of(T)
    items  := len(data)
    bytes  := stride * items

    if self.stride != stride || self.bytes != bytes {
        return false
    }

    gl.BindBuffer(gl.ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    gl.BufferSubData(gl.ARRAY_BUFFER, 0, bytes, &data[0])

    self.items = items

    return true
}

vertex_buffer_write_to_front :: proc(self: ^Vertex_Buffer, data: []$T) -> bool
{
    stride := size_of(T)
    items  := len(data)
    bytes  := stride * items

    if self.stride != stride || self.bytes < bytes {
        return false
    }

    gl.BindBuffer(gl.ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)

    gl.BufferSubData(gl.ARRAY_BUFFER, 0, bytes, &data[0])

    self.items = max(self.items, items)

    return true
}

vertex_buffer_write_to_range :: proc(self: ^Vertex_Buffer, data: []$T, range: [2]int) -> bool
{
    // TODO(gio): check if range is valid and if items surpass the current level, update them

    return false
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

index_buffer_make_with_storage :: proc(stride: int, items: int) -> (Index_Buffer, bool)
{
    value, state := index_buffer_make()

    if state == false { return value, state }

    state = index_buffer_set_storage(&value, stride, items)

    if state == false {
        index_buffer_destroy(&value)

        return {}, false
    }

    return value, true
}

index_buffer_destroy :: proc(self: ^Index_Buffer)
{
    handle := u32(self.handle)

    self.handle = 0
    self.bytes  = 0
    self.items  = 0

    gl.DeleteBuffers(1, &handle)
}

index_buffer_bind :: proc(self: ^Index_Buffer)
{
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, u32(self.handle))
}

index_buffer_unbind :: proc()
{
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
}

index_buffer_clear :: proc(self: ^Index_Buffer)
{
    self.items = 0
}

index_buffer_set_storage :: proc(self: ^Index_Buffer, stride: int, items: int) -> bool
{
    bytes := stride * items

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)

    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, bytes, nil,
        gl.DYNAMIC_DRAW)

    self.stride = stride
    self.bytes  = bytes

    return true
}

index_buffer_write_all :: proc(self: ^Index_Buffer, data: []$T) -> bool
{
    stride := size_of(T)
    items  := len(data)
    bytes  := stride * items

    if self.stride != stride || self.bytes != bytes {
        return false
    }

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)

    // NOTE(gio): map the buffer?
    gl.BufferSubData(gl.ELEMENT_ARRAY_BUFFER, 0, bytes, &data[0])

    self.items = items

    return true
}

index_buffer_write_to_front :: proc(self: ^Index_Buffer, data: []$T) -> bool
{
    stride := size_of(T)
    items  := len(data)
    bytes  := stride * items

    if self.stride != stride || self.bytes < bytes {
        return false
    }

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, u32(self.handle))

    defer gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)

    // NOTE(gio): map the buffer?
    gl.BufferSubData(gl.ELEMENT_ARRAY_BUFFER, 0, bytes, &data[0])

    self.items = max(self.items, items)

    return true
}

index_buffer_write_to_range :: proc(self: ^Index_Buffer, data: []$T, range: [2]int) -> bool
{
    // TODO(gio): Check if range is valid and if items surpass the current level, update them

    return false
}

vertex_layout_add_attrib :: proc(self: ^Vertex_Layout, type: Shader_Value_Type) -> bool
{
    index := self.items

    if type == .TYPE_NONE { return false }

    if index >= 0 && index < VERTEX_ATTRIB_MAX {
        self.items        += 1
        self.array[index]  = type

        return true
    }

    return false
}

vertex_layout_get_attrib_class :: proc(self: Vertex_Layout, index: int) -> int
{
    if index >= 0 && index < self.items {
        value := self.array[index]
        class := SHADER_VALUE_TYPE_CLASS[value]

        return class
    }

    return 0
}

vertex_layout_get_attrib_items :: proc(self: Vertex_Layout, index: int) -> int
{
    if index >= 0 && index < self.items {
        value := self.array[index]
        count := SHADER_VALUE_TYPE_ITEMS[value]

        return count
    }

    return 0
}

vertex_layout_get_attrib_offset :: proc(self: Vertex_Layout, index: int) -> int
{
    offset := 0

    if index < 0 || index >= self.items {
        return offset
    }

    for other in 1 ..= index {
        value := self.array[other - 1]
        bytes := SHADER_VALUE_TYPE_BYTES[value]

        offset += bytes
    }

    return offset
}

vertex_layout_get_stride :: proc(self: Vertex_Layout) -> int
{
    stride := 0

    for index in 0 ..< self.items {
        value := self.array[index]
        bytes := SHADER_VALUE_TYPE_BYTES[value]

        stride += bytes
    }

    return stride
}

@(private)
vertex_buffer_set_layout :: proc(self: ^Vertex_Buffer, layout: Vertex_Layout)
{
    stride := vertex_layout_get_stride(layout)

    for index in 0 ..< VERTEX_ATTRIB_MAX {
        gl.DisableVertexAttribArray(u32(index))
    }

    for index in 0 ..< layout.items {
        gl.EnableVertexAttribArray(u32(index))

        offset := vertex_layout_get_attrib_offset(layout, index)
        items  := vertex_layout_get_attrib_items(layout, index)
        class  := vertex_layout_get_attrib_class(layout, index)

        gl.VertexAttribPointer(u32(index), i32(items), u32(class),
            false, i32(stride), uintptr(offset))
    }
}

// TODO(gio): reintroduce
@(private)
BUFFER_USAGE := [Buffer_Usage]int {
    .USAGE_NONE         = 0,
    .USAGE_DYNAMIC_READ = gl.DYNAMIC_DRAW,
}
