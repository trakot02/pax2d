package graphics

import      "core:log"
import malg "core:math/linalg"

//
// Types
//

Rect_Batch :: struct
{
    view: ^View,

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

rect_batch_begin :: proc(self: ^Rect_Batch, view: ^View)
{
    self.view = view
}

rect_batch_end :: proc(self: ^Rect_Batch)
{
    total_vertices := len(self.vertices)
    start_vertices := 0
    stop_vertices  := 0
    total_indices  := len(self.indices)
    start_indices  := 0
    stop_indices   := 0

    shader_write_f32_mat4(&SHADER_RECT, "u_view",
        view_get_matrix(self.view))

    shader_write_i32_array(&SHADER_RECT, "u_samplers",
        {0, 1, 2, 3, 4, 5, 6, 7})

    shader_bind(&SHADER_RECT)

    texture_bundle_bind(&self.textures)
    sampler_bundle_bind(&self.samplers)

    for total_vertices > 0 && total_indices > 0 {
        delta_vertices := min(total_vertices, VERTEX_BUFFER_RECT_ITEMS)
        delta_indices  := min(total_indices, INDEX_BUFFER_RECT_ITEMS)

        total_vertices -= delta_vertices
        total_indices  -= delta_indices

        stop_vertices += delta_vertices
        stop_indices  += delta_indices

        vertex_buffer_write_to_front(&VERTEX_BUFFER_RECT,
            self.vertices[start_vertices:stop_vertices])

        index_buffer_write_to_front(&INDEX_BUFFER_RECT,
            self.indices[start_indices:stop_indices])

        paint_triangles_indexed(&VERTEX_BUFFER_RECT, &INDEX_BUFFER_RECT)

        start_vertices = stop_vertices
        start_indices  = stop_indices
    }

    sampler_bundle_unbind()
    texture_bundle_unbind()

    shader_unbind()

    sampler_bundle_clear(&self.samplers)
    texture_bundle_clear(&self.textures)

    clear(&self.vertices)
    clear(&self.indices)
}

rect_batch_texture_and_sampler :: proc(self: ^Rect_Batch, texture: ^Texture, sampler: ^Sampler) -> (int, bool)
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

rect_batch_vertices :: proc(self: ^Rect_Batch, vertices: []Rect_Vertex) -> bool
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

rect_batch_indices :: proc(self: ^Rect_Batch, indices: []u32) -> bool
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

rect_batch_add :: proc(self: ^Rect_Batch, rect: [4]f32, color: [4]f32, scale: [2]f32,
    part: [4]int, texture: ^Texture, sampler: ^Sampler) -> bool
{
    vertices := [4]Rect_Vertex {}
    indices  := [6]u32 {0, 1, 2, 2, 1, 3}

    index, state := rect_batch_texture_and_sampler(self,
        texture, sampler)

    if state == false { return false }

    vertices[1].point.y = rect.w
    vertices[2].point.x = rect.z
    vertices[3].point.y = rect.w
    vertices[3].point.x = rect.z

    vertices[1].texel.y = f32(part.w)
    vertices[2].texel.x = f32(part.z)
    vertices[3].texel.y = f32(part.w)
    vertices[3].texel.x = f32(part.z)

    for &item in vertices {
        item.color   = color
        item.texture = f32(index)

        item.texel = texture_normalize(texture,
            item.texel + {f32(part.x), f32(part.y)})

        item.point *= scale
        item.point += rect.xy
    }

    for &item in indices {
        item += u32(len(self.vertices))
    }

    state = rect_batch_vertices(self, vertices[:])

    if state == true {
        state = rect_batch_indices(self, indices[:])
    }

    return state
}

rect_batch_add_rotated :: proc(self: ^Rect_Batch, rect: [4]f32, color: [4]f32, scale: [2]f32, angle: f32, pivot: [2]f32,
    part: [4]int, texture: ^Texture, sampler: ^Sampler) -> bool
{
    vertices := [4]Rect_Vertex {}
    indices  := [6]u32 {0, 1, 2, 2, 1, 3}
    rotation := malg.matrix2_rotate_f32(angle)

    index, state := rect_batch_texture_and_sampler(self,
        texture, sampler)

    if state == false { return false }

    vertices[1].point.y = rect.w
    vertices[2].point.x = rect.z
    vertices[3].point.y = rect.w
    vertices[3].point.x = rect.z

    vertices[1].texel.y = f32(part.w)
    vertices[2].texel.x = f32(part.z)
    vertices[3].texel.y = f32(part.w)
    vertices[3].texel.x = f32(part.z)

    for &item in vertices {
        item.color   = color
        item.texture = f32(index)

        item.texel = texture_normalize(texture,
            item.texel + {f32(part.x), f32(part.y)})

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

    state = rect_batch_vertices(self, vertices[:])

    if state == true {
        state = rect_batch_indices(self, indices[:])
    }

    return state
}
