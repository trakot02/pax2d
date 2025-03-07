package graphics

import      "core:log"
import malg "core:math/linalg"

//
// Types
//

Rect_Batch :: struct
{
    textures: Texture_Bundle,
    samplers: Sampler_Bundle,

    vertices: [dynamic]Rect_Vertex,
}

//
// Procs
//

rect_batch_make :: proc(allocator := context.allocator) -> Rect_Batch
{
    value := Rect_Batch {}

    value.vertices = make([dynamic]Rect_Vertex, allocator)

    return value
}

rect_batch_destroy :: proc(self: ^Rect_Batch)
{
    delete(self.vertices)

    self.vertices = {}
}

rect_batch_begin :: proc(self: ^Rect_Batch)
{

}

rect_batch_end :: proc(self: ^Rect_Batch)
{
    items := len(self.vertices)
    start := 0
    stop  := 0

    shader_bind(&SHADER_RECT)

    texture_bundle_bind(&self.textures)
    sampler_bundle_bind(&self.samplers)

    for ; items > 0; start = stop {
        delta := min(items, VERTEX_BUFFER_RECT_ITEMS)

        items -= delta
        stop  += delta

        vertex_buffer_write_to_front(&VERTEX_BUFFER_RECT,
            self.vertices[start:stop])

        paint_triangles(&VERTEX_BUFFER_RECT)

        vertex_buffer_clear(&VERTEX_BUFFER_RECT)
    }

    sampler_bundle_unbind()
    texture_bundle_unbind()

    shader_unbind()

    sampler_bundle_clear(&self.samplers)
    texture_bundle_clear(&self.textures)

    clear(&self.vertices)
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

rect_batch_vertices_and_indices :: proc(self: ^Rect_Batch, vertices: []Rect_Vertex, indices: []int) -> bool
{
    items := len(self.vertices)

    for index in indices {
        _, error := append(&self.vertices, vertices[index])

        if error != nil {
            log.errorf("Rect_Batch: Unable to add vertices or indices")

            resize(&self.vertices, items)

            return false
        }
    }

    return true
}

rect_batch_add :: proc(self: ^Rect_Batch, rect: [4]f32, color: [4]f32, scale: [2]f32,
    part: [4]int, texture: ^Texture, sampler: ^Sampler) -> bool
{
    vertices := [4]Rect_Vertex {}

    index, state := rect_batch_texture_and_sampler(self, texture, sampler)

    if state == false { return false }

    vertices[1].point.y = rect.w
    vertices[2].point.x = rect.z
    vertices[3].point.y = rect.w
    vertices[3].point.x = rect.z

    vertices[1].texel.y = f32(part.w)
    vertices[2].texel.x = f32(part.z)
    vertices[3].texel.y = f32(part.w)
    vertices[3].texel.x = f32(part.z)

    center := [2]f32 {
        rect.z * 0.5, rect.w * 0.5,
    }

    for &item in vertices {
        item.color   = color
        item.texture = f32(index)

        item.texel = texture_normalize(texture,
            item.texel + {f32(part.x), f32(part.y)})

        item.point -= center
        item.point *= scale
        item.point += center
        item.point += rect.xy
    }

    return rect_batch_vertices_and_indices(self, vertices[:],
        {0, 1, 2, 2, 1, 3})
}

rect_batch_add_rotated :: proc(self: ^Rect_Batch, rect: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32,
    part: [4]int, texture: ^Texture, sampler: ^Sampler) -> bool
{
    vertices := [4]Rect_Vertex {}
    rotation := malg.matrix2_rotate_f32(angle)

    index, state := rect_batch_texture_and_sampler(self, texture, sampler)

    if state == false { return false }

    vertices[1].point.y = rect.w
    vertices[2].point.x = rect.z
    vertices[3].point.y = rect.w
    vertices[3].point.x = rect.z

    vertices[1].texel.y = f32(part.w)
    vertices[2].texel.x = f32(part.z)
    vertices[3].texel.y = f32(part.w)
    vertices[3].texel.x = f32(part.z)

    center := [2]f32 {
        rect.z * (0.5 + pivot.x), rect.w * (0.5 + pivot.y),
    }

    for &item in vertices {
        item.color   = color
        item.texture = f32(index)

        item.texel = texture_normalize(texture,
            item.texel + {f32(part.x), f32(part.y)})

        item.point -= center
        item.point *= rotation
        item.point += center
        item.point += rect.xy
    }

    return rect_batch_vertices_and_indices(self, vertices[:],
        {0, 1, 2, 2, 1, 3})
}

rect_batch_add_general :: proc(self: ^Rect_Batch, rect: [4]f32, color: [4]f32, scale: [2]f32, angle: f32, pivot: [2]f32,
    part: [4]int, texture: ^Texture, sampler: ^Sampler) -> bool
{
    vertices := [4]Rect_Vertex {}
    rotation := malg.matrix2_rotate_f32(angle)

    index, state := rect_batch_texture_and_sampler(self, texture, sampler)

    if state == false { return false }

    vertices[1].point.y = rect.w
    vertices[2].point.x = rect.z
    vertices[3].point.y = rect.w
    vertices[3].point.x = rect.z

    vertices[1].texel.y = f32(part.w)
    vertices[2].texel.x = f32(part.z)
    vertices[3].texel.y = f32(part.w)
    vertices[3].texel.x = f32(part.z)

    center := [2]f32 {
        rect.z * (0.5 + pivot.x), rect.w * (0.5 + pivot.y),
    }

    for &item in vertices {
        item.color   = color
        item.texture = f32(index)

        item.texel = texture_normalize(texture,
            item.texel + {f32(part.x), f32(part.y)})

        item.point -= center
        item.point *= scale
        item.point *= rotation
        item.point += center
        item.point += rect.xy
    }

    return rect_batch_vertices_and_indices(self, vertices[:],
        {0, 1, 2, 2, 1, 3})
}
