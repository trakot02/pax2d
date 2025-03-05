package pax2d

import "core:log"

//
// Types
//

Render_Batch :: struct
{
    shader: ^Shader,

    vertices: Vertex_Buffer,

    textures: Texture_Bundle,
    samplers: Sampler_Bundle,
}

Renderer :: struct
{
    shader: ^Shader,

    vertices: [dynamic]Render_Vertex,

    textures: [dynamic]^Texture,
    samplers: [dynamic]^Sampler,
}

//
// Procs
//

renderer_start :: proc()
{

}

render_stop :: proc()
{

}

render_clear :: proc(self: ^Render_State, color: [4]f32)
{
    gl.ClearColor(color.r, color.g, color.b, color.a)

    gl.Clear(gl.COLOR_BUFFER_BIT | gl.COLOR_DEPTH_BIT)
}

render_begin :: proc()
{

}

render_end :: proc(self: ^Render_State)
{
    render_batch_flush(&self.batch)
}

render_rect :: proc(self: ^Render_State, rect: [4]f32, color: [4]f32, scale: [2]f32 = {1, 1})
{
    render_batch_rect(&self.batch, rect, color, scale)
}

render_rect_rotated :: proc(self: ^Render_State, rect: [4]f32, color: [4]f32, angle: f32, pivot: [2]f32 = {0.5, 0.5})
{
    
}

render_rect_general :: proc(self: ^Render_State, rect: [4]f32, color: [4]f32, scale: [2]f32, angle: f32, pivot: [2]f32)
{

}

render_batch_make :: proc(allocator := context.allocator) -> (Render_Batch, bool)
{
    value := Render_Batch {}
    state := true

    value.vertices = make([dynamic]Render_Vertex, allocator)

    value.buffer, state = pfx.vertex_buffer_make()

    if state == true {
        pfx.vertex_buffer_set_layout(&value.buffer,
            RENDER_VERTEX_LAYOUT)

        state = pfx.vertex_buffer_ask_storage(&value.buffer,
            .USAGE_DYNAMIC_READ, VERTEX_BUFFER_BYTES)
    }

    if state == false {
        pfx.vertex_buffer_destroy(&value.buffer)
    }

    return value, state
}

render_batch_destroy :: proc(self: ^Render_Batch)
{
    pfx.vertex_buffer_destroy(&self.buffer)

    delete(self.vertices)

    self.textures = {}
    self.samplers = {}
    self.vertices = {}
}

render_batch_flush :: proc(self: ^Render_Batch)
{
    items := len(self.vertices)

    if items != 0 {
        shader_bind(&DEFAULT_SHADER)

        texture_bundle_bind(&self.textures)
        sampler_bundle_bind(&self.samplers)

        vertex_buffer_write_front(&self.buffer, self.vertices[:])

        clear(&self.vertices)

        paint(&self.buffer)

        sampler_bundle_unbind()
        texture_bundle_unbind()

        shader_unbind()
    }
}

render_batch_rect :: proc(self: ^Render_Batch, rect: [4]f32, color: [4]f32, scale: [2]f32) -> bool
{
    verts := [4]Render_Vertex {}
    items := len(self.vertices)

    index, state := render_batch_add_texture(self,
        &DEFAULT_TEXTURE, &DEFAULT_SAMPLER)

    if state == false { return false }

    for &item in verts {
        item.point   = {rect.x, rect.y}
        item.color   = color
        item.texture = f32(index)
    }

    verts[1].point.x += rect.z
    verts[2].point.y += rect.w
    verts[3].point.x += rect.z
    verts[3].point.y += rect.w

    verts[1].texel.x += 1
    verts[2].texel.y += 1
    verts[3].texel.x += 1
    verts[3].texel.y += 1

    indxs := [6]int {0, 2, 1, 1, 2, 3}

    for item in indxs {
        _, error := append(&self.vertices, verts[item])

        if error != nil {
            log.errorf("Render_Batch: Unable to add rect vertex")

            resize(&self.vertices, items)

            return false
        }
    }

    return true
}

VERTEX_BUFFER_ITEMS  :: 2048
VERTEX_BUFFER_BYTES  :: VERTEX_BUFFER_ITEMS * size_of(Render_Vertex)
