package opengl

import gl "vendor:OpenGL"

//
// Types
//

Geometry_Batch :: struct
{
    handle: int,

    vertices: Vertex_Buffer,
    indices:  Index_Buffer,
}

//
// Procs
//

geometry_batch_make :: proc() -> (Geometry_Batch, bool)
{
    handle := u32 {}
    value  := Geometry_Batch {}

    gl.GenVertexArrays(1, &handle)

    if handle != 0 {
        value.handle = int(handle)
    }

    return value, handle != 0
}

geometry_batch_alloc :: proc(limit: int, $V: typeid, $I: typeid) -> (Geometry_Batch, bool)
{
    value, state := geometry_batch_make()

    if state == false { return value, state }

    value.vertices, state = vertex_buffer_alloc(limit, V)

    if state == true {
        value.indices, state = index_buffer_alloc(limit, I)
    }

    if state == false { geometry_batch_destroy(&value) }

    return value, state
}

geometry_batch_destroy :: proc(self: ^Geometry_Batch)
{
    handle := u32(self.handle)

    self.handle = 0

    gl.DeleteVertexArrays(1, &handle)

    index_buffer_destroy(&self.indices)
    vertex_buffer_destroy(&self.vertices)
}

geometry_batch_get_vertex_size :: proc(self: ^Geometry_Batch) -> int
{
    return vertex_buffer_get_size(&self.vertices)
}

geometry_batch_get_index_size :: proc(self: ^Geometry_Batch) -> int
{
    return index_buffer_get_size(&self.indices)
}

geometry_batch_clear :: proc(self: ^Geometry_Batch)
{
    vertex_buffer_clear(&self.vertices)
    index_buffer_clear(&self.indices)
}

geometry_batch_realloc :: proc(self: ^Geometry_Batch, limit: int, $V: typeid, $I: typeid) -> bool
{
    vertex_buffer_realloc(&self.vertices, limit, V)
    index_buffer_realloc(&self.indices, limit, I)

    return true
}

geometry_batch_apply_layout :: proc(self: ^Geometry_Batch, layout: ^Vertex_Layout) -> bool
{
    if layout == nil { return false }

    gl.BindVertexArray(u32(self.handle))

    gl.BindBuffer(gl.ARRAY_BUFFER, u32(self.vertices.handle))
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, u32(self.indices.handle))

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

geometry_batch_write_all :: proc(self: ^Geometry_Batch, vertices: []$V, indices: []$I)
{
    vertex_buffer_write_all(&self.vertices, vertices)
    index_buffer_write_all(&self.indices, indices)
}

geometry_batch_write_to_front :: proc(self: ^Geometry_Batch, vertices: []$V, indices: []$I)
{
    vertex_buffer_write_to_front(&self.vertices, vertices)
    index_buffer_write_to_front(&self.indices, indices)
}
