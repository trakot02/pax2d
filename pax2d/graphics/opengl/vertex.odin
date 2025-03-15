package opengl

import gl "vendor:OpenGL"

//
// Values
//

VERTEX_ATTRIB_MAX :: int(8)

//
// Types
//

Vertex_Attrib_Type :: enum
{
    TYPE_NONE,
    TYPE_I32,
    TYPE_I32_VEC2,
    TYPE_I32_VEC3,
    TYPE_I32_VEC4,
    TYPE_F32,
    TYPE_F32_VEC2,
    TYPE_F32_VEC3,
    TYPE_F32_VEC4,
}

Vertex_Attrib :: struct
{
    type: Vertex_Attrib_Type,
}

Vertex_Layout :: struct
{
    array: [VERTEX_ATTRIB_MAX]Vertex_Attrib,
    items: int,
}

Vertex_Spec :: struct
{
    handle: int,
}

//
// Procs
//

vertex_layout_clear :: proc(self: ^Vertex_Layout)
{
    self.items = 0
}

vertex_layout_add :: proc(self: ^Vertex_Layout, attrib: Vertex_Attrib) -> bool
{
    index := self.items

    if attrib.type == .TYPE_NONE { return false }

    if index >= 0 && index < len(self.array) {
        self.items        += 1
        self.array[index]  = attrib

        return true
    }

    return false
}

vertex_layout_get_kind :: proc(self: ^Vertex_Layout, index: int) -> int
{
    if index >= 0 && index < self.items {
        return VERTEX_ATTRIB_TYPE_KIND[self.array[index].type]
    }

    return 0
}

vertex_layout_get_mult :: proc(self: ^Vertex_Layout, index: int) -> int
{
    if index >= 0 && index < self.items {
        return VERTEX_ATTRIB_TYPE_MULT[self.array[index].type]
    }

    return 0
}

vertex_layout_get_offset :: proc(self: ^Vertex_Layout, index: int) -> int
{
    offset := 0

    if index < 0 || index >= self.items { return offset }

    for other in 1 ..= index {
        offset += VERTEX_ATTRIB_TYPE_SIZE[self.array[other - 1].type]
    }

    return offset
}

vertex_layout_get_stride :: proc(self: ^Vertex_Layout) -> int
{
    stride := 0

    for index in 0 ..< self.items {
        stride += VERTEX_ATTRIB_TYPE_SIZE[self.array[index].type]
    }

    return stride
}

vertex_spec_make :: proc() -> (Vertex_Spec, bool)
{
    handle := u32 {}
    value  := Vertex_Spec {}

    gl.GenVertexArrays(1, &handle)

    if handle != 0 {
        value.handle = int(handle)
    }

    return value, handle != 0
}

vertex_spec_destroy :: proc(self: ^Vertex_Spec)
{
    handle := u32(self.handle)

    self.handle = 0

    gl.DeleteVertexArrays(1, &handle)
}

vertex_spec_apply :: proc(self: ^Vertex_Spec, layout: ^Vertex_Layout, vertices: ^Vertex_Buffer, indices: ^Index_Buffer) -> bool
{
    if vertices == nil || layout == nil { return false }

    gl.BindVertexArray(u32(self.handle))

    gl.BindBuffer(gl.ARRAY_BUFFER, u32(vertices.handle))

    if indices != nil {
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, u32(indices.handle))
    }

    defer gl.BindVertexArray(0)

    stride := vertex_layout_get_stride(layout)

    for item in 0 ..< layout.items {
        gl.EnableVertexAttribArray(u32(item))

        offset := vertex_layout_get_offset(layout, item)
        kind   := vertex_layout_get_kind(layout, item)
        mult   := vertex_layout_get_mult(layout, item)

        gl.VertexAttribPointer(u32(item), i32(mult), u32(kind),
            false, i32(stride), uintptr(offset))
    }

    for item in layout.items ..< len(layout.array) {
        gl.DisableVertexAttribArray(u32(item))
    }

    return true
}

@(private)
VERTEX_ATTRIB_TYPE_KIND := [Vertex_Attrib_Type]int {
    .TYPE_NONE      = 0,
    .TYPE_I32       = gl.INT,
    .TYPE_I32_VEC2  = gl.INT,
    .TYPE_I32_VEC3  = gl.INT,
    .TYPE_I32_VEC4  = gl.INT,
    .TYPE_F32       = gl.FLOAT,
    .TYPE_F32_VEC2  = gl.FLOAT,
    .TYPE_F32_VEC3  = gl.FLOAT,
    .TYPE_F32_VEC4  = gl.FLOAT,
}

@(private)
VERTEX_ATTRIB_TYPE_MULT := [Vertex_Attrib_Type]int {
    .TYPE_NONE      = 0,
    .TYPE_I32       = 1,
    .TYPE_I32_VEC2  = 2,
    .TYPE_I32_VEC3  = 3,
    .TYPE_I32_VEC4  = 4,
    .TYPE_F32       = 1,
    .TYPE_F32_VEC2  = 2,
    .TYPE_F32_VEC3  = 3,
    .TYPE_F32_VEC4  = 4,
}

@(private)
VERTEX_ATTRIB_TYPE_SIZE := [Vertex_Attrib_Type]int {
    .TYPE_NONE      = 0,
    .TYPE_I32       = size_of(i32) * 1,
    .TYPE_I32_VEC2  = size_of(i32) * 2,
    .TYPE_I32_VEC3  = size_of(i32) * 3,
    .TYPE_I32_VEC4  = size_of(i32) * 4,
    .TYPE_F32       = size_of(f32) * 1,
    .TYPE_F32_VEC2  = size_of(f32) * 2,
    .TYPE_F32_VEC3  = size_of(f32) * 3,
    .TYPE_F32_VEC4  = size_of(f32) * 4,
}
