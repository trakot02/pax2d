package graphics

import      "core:log"
import malg "core:math/linalg"

//
// Types
//

Rect_Batch :: struct
{
    view:   ^View,
    shader: ^Shader,

    textures: Texture_Bundle,
    samplers: Sampler_Bundle,

    vertices: [dynamic]Rect_Vertex,
    indices:  [dynamic]u32,
}

//
// Procs
//

rect_batch_make :: proc(allocator := context.allocator) -> Rect_Batch
{
    value := Rect_Batch {}

    value.vertices = make([dynamic]Rect_Vertex, allocator)
    value.indices  = make([dynamic]u32, allocator)

    return value
}

rect_batch_destroy :: proc(self: ^Rect_Batch)
{
    delete(self.indices)
    delete(self.vertices)

    self.vertices = {}
    self.indices  = {}
}

rect_batch_clear :: proc(self: ^Rect_Batch)
{
    self.shader = nil

    texture_bundle_clear(&self.textures)
    sampler_bundle_clear(&self.samplers)

    clear(&self.vertices)
    clear(&self.indices)
}

rect_batch_apply :: proc(self: ^Rect_Batch)
{
    vertices_count := len(self.vertices)
    vertices_range := [2]int {}

    indices_count := len(self.indices)
    indices_range := [2]int {}

    if self.shader == nil || self.view == nil { return }

    shader_write_f32_mat4(self.shader, "u_view",
        view_get_matrix(self.view))

    shader_write_i32_array(self.shader, "u_samplers",
        {0, 1, 2, 3, 4, 5, 6, 7})

    shader_bind(self.shader)

    texture_bundle_bind(&self.textures)
    sampler_bundle_bind(&self.samplers)

    for vertices_count > 0 && indices_count > 0 {
        vertices_delta   := min(vertices_count, VERTEX_BUFFER_RECT_ITEMS)
        vertices_count   -= vertices_delta
        vertices_range.y += vertices_delta

        vertex_buffer_write_to_front(&VERTEX_BUFFER_RECT,
            self.vertices[vertices_range.x:vertices_range.y])

        vertices_range.x = vertices_range.y

        indices_delta   := min(indices_count, INDEX_BUFFER_RECT_ITEMS)
        indices_count   -= indices_delta
        indices_range.y += indices_delta

        index_buffer_write_to_front(&INDEX_BUFFER_RECT,
            self.indices[indices_range.x:indices_range.y])

        indices_range.x = indices_range.y

        paint_triangles_indexed(&VERTEX_BUFFER_RECT, &INDEX_BUFFER_RECT)
    }

    sampler_bundle_unbind()
    texture_bundle_unbind()

    shader_unbind()
}

rect_batch_set_view :: proc(self: ^Rect_Batch, view: ^View)
{
    self.view = view
}

rect_batch_set_shader :: proc(self: ^Rect_Batch, shader: ^Shader)
{
    self.shader = shader
}

rect_batch_add_texture_and_sampler :: proc(self: ^Rect_Batch, texture: ^Texture, sampler: ^Sampler) -> (int, bool)
{
    index := texture_bundle_index_of(&self.textures, texture)
    other := sampler_bundle_index_of(&self.samplers, sampler)

    items := self.textures.items

    if items != self.samplers.items { return 0, false }

    if index >= 0 && index < items &&
       other >= 0 && other < items &&
       index == other { return index, true }

    state := texture_bundle_add(&self.textures, texture)

    if state == true {
        state = sampler_bundle_add(&self.samplers, sampler)
    }

    if state == false {
        self.textures.items = items
        self.samplers.items = items

        log.errorf("Rect_Batch: Unable to add texture or sampler")

        return 0, false
    }

    return items, true
}

rect_batch_add_vertices :: proc(self: ^Rect_Batch, vertices: []Rect_Vertex) -> bool
{
    items := len(self.vertices)

    for item in vertices {
        _, error := append(&self.vertices, item)

        if error != nil {
            log.errorf("Rect_Batch: Unable to add vertices")

            resize(&self.vertices, items)

            return false
        }
    }

    return true
}

rect_batch_add_indices :: proc(self: ^Rect_Batch, indices: []u32) -> bool
{
    items := len(self.indices)

    for item in indices {
        _, error := append(&self.indices, item)

        if error != nil {
            log.errorf("Rect_Batch: Unable to add indices")

            resize(&self.indices, items)

            return false
        }
    }

    return true
}

rect_batch_add :: proc(self: ^Rect_Batch, rect: [4]f32, color: [4]f32, scale: [2]f32, section: [4]int, texture: ^Texture, sampler: ^Sampler) -> bool
{
    vertices := [4]Rect_Vertex {}
    indices  := [6]u32 {0, 1, 2, 2, 1, 3}

    index, state := rect_batch_add_texture_and_sampler(
        self, texture, sampler)

    if state == false { return false }

    vertices[1].point.y = rect.w
    vertices[2].point.x = rect.z
    vertices[3].point.y = rect.w
    vertices[3].point.x = rect.z

    vertices[1].texel.y = f32(section.w)
    vertices[2].texel.x = f32(section.z)
    vertices[3].texel.y = f32(section.w)
    vertices[3].texel.x = f32(section.z)

    for &item in vertices {
        item.color   = color
        item.texture = f32(index)

        item.texel = texture_normalize(texture,
            item.texel + {f32(section.x), f32(section.y)})

        item.point *= scale
        item.point += rect.xy
    }

    for &item in indices {
        item += u32(len(self.vertices))
    }

    state = rect_batch_add_vertices(self, vertices[:])

    if state == true {
        state = rect_batch_add_indices(self, indices[:])
    }

    return state
}

rect_batch_add_rotated :: proc(self: ^Rect_Batch, rect: [4]f32, color: [4]f32, scale: [2]f32, angle: f32, pivot: [2]f32, section: [4]int, texture: ^Texture, sampler: ^Sampler) -> bool
{
    vertices := [4]Rect_Vertex {}
    indices  := [6]u32 {0, 1, 2, 2, 1, 3}
    rotation := malg.matrix2_rotate_f32(angle)

    index, state := rect_batch_add_texture_and_sampler(
        self, texture, sampler)

    if state == false { return false }

    vertices[1].point.y = rect.w
    vertices[2].point.x = rect.z
    vertices[3].point.y = rect.w
    vertices[3].point.x = rect.z

    vertices[1].texel.y = f32(section.w)
    vertices[2].texel.x = f32(section.z)
    vertices[3].texel.y = f32(section.w)
    vertices[3].texel.x = f32(section.z)

    for &item in vertices {
        item.color   = color
        item.texture = f32(index)

        item.texel = texture_normalize(texture,
            item.texel + {f32(section.x), f32(section.y)})

        item.point -= rect.zw / 2

        item.point *= scale
        item.point -= pivot * rect.zw
        item.point *= rotation
        item.point += pivot * rect.zw
        item.point += rect.xy

        item.point += rect.zw / 2
    }

    for &item in indices {
        item += u32(len(self.vertices))
    }

    state = rect_batch_add_vertices(self, vertices[:])

    if state == true {
        state = rect_batch_add_indices(self, indices[:])
    }

    return state
}
