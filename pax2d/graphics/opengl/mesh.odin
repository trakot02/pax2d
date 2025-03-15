package opengl

//
// Types
//

Mesh :: struct
{
    spec: Vertex_Spec,

    vertices: Vertex_Buffer,
    indices:  Index_Buffer,
}

//
// Procs
//

mesh_make :: proc($V: typeid, $I: typeid, limit: int) -> (Mesh, bool)
{
    value := Mesh {}
    state := true

    value.spec, state = vertex_spec_make()

    if state == true { value.vertices, state = vertex_buffer_alloc(limit, V) }
    if state == true { value.indices,  state = index_buffer_alloc(limit, I) }

    if state == false {
        index_buffer_destroy(&value.indices)
        vertex_buffer_destroy(&value.vertices)

        vertex_spec_destroy(&value.spec)
    }

    return value, state
}

mesh_destroy :: proc(self: ^Mesh)
{
    index_buffer_destroy(&self.indices)
    vertex_buffer_destroy(&self.vertices)

    vertex_spec_destroy(&self.spec)
}

mesh_clear :: proc(self: ^Mesh)
{
    vertex_buffer_clear(&self.vertices)
    index_buffer_clear(&self.indices)
}

mesh_apply_layout :: proc(self: ^Mesh, layout: ^Vertex_Layout)
{
    vertex_spec_apply(&self.spec, layout, &self.vertices, &self.indices)
}

mesh_write_vertices :: proc(self: ^Mesh, vertices: []$T) -> bool
{
    return vertex_buffer_write_to_front(&self.vertices, vertices)
}

mesh_write_indices :: proc(self: ^Mesh, indices: []$T) -> bool
{
    return index_buffer_write_to_front(&self.indices, indices)
}
