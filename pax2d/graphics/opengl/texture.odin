package opengl

import gl "vendor:OpenGL"

//
// Values
//

TEXTURE_SLOT_MAX :: SAMPLER_SLOT_MAX

//
// Types
//

Texture_Layout :: enum
{
    LAYOUT_NONE,
    LAYOUT_RGB,
    LAYOUT_RGBA,
}

Texture :: struct
{
    handle: int,
    layout: Texture_Layout,
    bytes:  int,
    items:  [2]int,
}

Texture_Bundle_Array :: [TEXTURE_SLOT_MAX]^Texture

Texture_Bundle :: struct
{
    array: Texture_Bundle_Array,
    items: int,
}

//
// Procs
//

texture_make :: proc() -> (Texture, bool)
{
    handle := u32 {}
    value  := Texture {}

    gl.GenTextures(1, &handle)

    if handle != 0 {
        value.handle = int(handle)
    }

    return value, handle != 0
}

texture_make_with_storage :: proc(layout: Texture_Layout, items: [2]int) -> (Texture, bool)
{
    value, state := texture_make()

    if state == false { return value, state }

    state = texture_set_storage(&value, layout, items)

    if state == false {
        texture_destroy(&value)

        return {}, false
    }

    return value, true
}

/*
texture_from_image :: proc(self: ^Texture, image: Image) -> bool
{
    format := IMAGE_TO_TEXTURE_FORMAT[image.format]

    if format == .NONE { return false }

    texture_set_storage(self, format, image.items) or_return

    return texture_send_data(self, format, image.data)
}

texture_from_file :: proc(self: ^Texture, filename: string) -> bool
{
    assert(false, "Not implemented yet")

    return false
}
*/

texture_destroy :: proc(self: ^Texture)
{
    handle := u32(self.handle)

    self.handle = 0

    gl.DeleteTextures(1, &handle)
}

texture_bind :: proc(self: ^Texture, slot: int = 0) -> bool
{
    if slot < 0 || slot >= TEXTURE_SLOT_MAX {
        return false
    }

    gl.ActiveTexture(gl.TEXTURE0 + u32(slot))
    gl.BindTexture(gl.TEXTURE_2D, u32(self.handle))

    return true
}

texture_unbind :: proc()
{
    for slot in 0 ..< TEXTURE_SLOT_MAX {
        gl.ActiveTexture(gl.TEXTURE0 + u32(slot))
        gl.BindTexture(gl.TEXTURE_2D, 0)
    }
}

texture_set_storage :: proc(self: ^Texture, layout: Texture_Layout, items: [2]int) -> bool
{
    layout_value := TEXTURE_LAYOUT[layout]

    if layout == .LAYOUT_NONE { return false }

    width  := i32(items.x)
    height := i32(items.y)

    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, u32(self.handle))

    defer gl.BindTexture(gl.TEXTURE_2D, 0)

    gl.TexImage2D(gl.TEXTURE_2D, 0, i32(layout_value),
        width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, nil)

    comps := TEXTURE_LAYOUT_COMPS[layout]
    bytes := comps * items.x * items.y

    self.layout = layout
    self.bytes  = bytes
    self.items  = items

    return true
}

texture_write_all :: proc(self: ^Texture, layout: Texture_Layout, data: []byte) -> bool
{
    layout_value := TEXTURE_LAYOUT[layout]

    bytes := len(data)

    if layout == .LAYOUT_NONE { return false }
    if layout != self.layout  { return false }
    if bytes  != self.bytes   { return false }

    width  := i32(self.items.x)
    height := i32(self.items.y)

    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, u32(self.handle))

    defer gl.BindTexture(gl.TEXTURE_2D, 0)

    gl.TexSubImage2D(gl.TEXTURE_2D, 0, 0, 0, width, height,
        u32(layout_value), gl.UNSIGNED_BYTE, &data[0])

    return true
}

texture_write_to_range :: proc(self: ^Texture, layout: Texture_Layout, data: []byte, range: [4]int) -> bool
{
    layout_value := TEXTURE_LAYOUT[layout]

    if layout == .LAYOUT_NONE { return false }
    if layout != self.layout  { return false }

    left   := (range.x < 0)
    top    := (range.x + range.z >= self.items.x)
    right  := (range.y < 0)
    bottom := (range.y + range.w >= self.items.y)

    if left || top || right || bottom { return false }

    width  := i32(range.z)
    height := i32(range.w)

    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, u32(self.handle))

    defer gl.BindTexture(gl.TEXTURE_2D, 0)

    gl.TexSubImage2D(gl.TEXTURE_2D, 0, 0, 0, width, height,
        u32(layout_value), gl.UNSIGNED_BYTE, &data[0])

    return true
}

texture_bundle_clear :: proc(self: ^Texture_Bundle)
{
    self.items = 0
}

texture_bundle_find :: proc(self: ^Texture_Bundle, texture: ^Texture) -> (int, bool)
{
    for index in 0 ..< self.items {
        value := self.array[index]

        if value.handle == texture.handle {
            return index, true
        }
    }

    return 0, false
}

texture_bundle_add :: proc(self: ^Texture_Bundle, texture: ^Texture) -> (int, bool)
{
    index, state := texture_bundle_find(self, texture)

    if state == true { return index, state }

    index = self.items

    if index >= 0 && index < TEXTURE_SLOT_MAX {
        self.items        += 1
        self.array[index]  = texture

        return index, true
    }

    return 0, false
}

texture_bundle_bind :: proc(self: ^Texture_Bundle)
{
    for index in 0 ..< self.items {
        texture_bind(self.array[index], index)
    }
}

texture_bundle_unbind :: proc()
{
    texture_unbind()
}

@(private)
TEXTURE_LAYOUT_COMPS := [Texture_Layout]int {
    .LAYOUT_NONE = 0,
    .LAYOUT_RGB  = 3,
    .LAYOUT_RGBA = 4,
}

/*
@(private)
IMAGE_TO_TEXTURE_LAYOUT := [Image_Format]Texture_Layout {
    .NONE = .LAYOUT_NONE,
    .RGB  = .LAYOUT_RGB,
    .RGBA = .LAYOUT_RGBA,
}
*/

@(private)
TEXTURE_LAYOUT := [Texture_Layout]int {
    .LAYOUT_NONE = 0,
    .LAYOUT_RGB  = gl.RGB,
    .LAYOUT_RGBA = gl.RGBA,
}
