package opengl

import gl "vendor:OpenGL"

//
// Values
//

TEXTURE_SLOT_MAX :: SAMPLER_SLOT_MAX

//
// Types
//

Texture_Format :: enum
{
    TEXTURE_NONE,
    TEXTURE_RGB,
    TEXTURE_RGBA,
}

Texture :: struct
{
    handle: int,
    format: Texture_Format,
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

texture_make_with_storage :: proc(format: Texture_Format, items: [2]int) -> (Texture, bool)
{
    value, state := texture_make()

    if state == false { return value, state }

    state = texture_set_storage(&value, format, items)

    if state == false {
        texture_destroy(&value)
    }

    return value, state
}

texture_destroy :: proc(self: ^Texture)
{
    handle := u32(self.handle)

    self.handle = 0
    self.format = .TEXTURE_NONE
    self.bytes  = 0
    self.items  = {}

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

texture_set_storage :: proc(self: ^Texture, format: Texture_Format, items: [2]int) -> bool
{
    format_value := TEXTURE_FORMAT[format]

    if format == .TEXTURE_NONE { return false }

    width  := i32(items.x)
    height := i32(items.y)

    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, u32(self.handle))

    defer gl.BindTexture(gl.TEXTURE_2D, 0)

    gl.TexImage2D(gl.TEXTURE_2D, 0, i32(format_value),
        width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, nil)

    comps := TEXTURE_FORMAT_COMPS[format]
    bytes := comps * items.x * items.y

    self.format = format
    self.bytes  = bytes
    self.items  = items

    return true
}

texture_write_all :: proc(self: ^Texture, format: Texture_Format, data: []byte) -> bool
{
    format_value := TEXTURE_FORMAT[format]

    bytes := len(data)

    if format == .TEXTURE_NONE { return false }
    if format != self.format  { return false }
    if bytes  != self.bytes   { return false }

    width  := i32(self.items.x)
    height := i32(self.items.y)

    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, u32(self.handle))

    defer gl.BindTexture(gl.TEXTURE_2D, 0)

    // NOTE(gio): map the texture?
    gl.TexSubImage2D(gl.TEXTURE_2D, 0, 0, 0, width, height,
        u32(format_value), gl.UNSIGNED_BYTE, &data[0])

    return true
}

texture_write_to_range :: proc(self: ^Texture, format: Texture_Format, data: []byte, range: [4]int) -> bool
{
    format_value := TEXTURE_FORMAT[format]

    if format == .TEXTURE_NONE { return false }
    if format != self.format  { return false }

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

    // NOTE(gio): map the texture?
    gl.TexSubImage2D(gl.TEXTURE_2D, 0, 0, 0, width, height,
        u32(format_value), gl.UNSIGNED_BYTE, &data[0])

    return true
}

texture_normalize :: proc(self: ^Texture, point: [2]f32) -> [2]f32
{
    return [2]f32 {
        point.x / f32(self.items.x),
        point.y / f32(self.items.y),
    }
}

texture_bundle_clear :: proc(self: ^Texture_Bundle)
{
    self.items = 0
}

texture_bundle_index_of :: proc(self: ^Texture_Bundle, texture: ^Texture) -> int
{
    for index in 0 ..< self.items {
        value := self.array[index]

        if value.handle == texture.handle {
            return index
        }
    }

    return TEXTURE_SLOT_MAX
}

texture_bundle_add :: proc(self: ^Texture_Bundle, texture: ^Texture) -> bool
{
    index := self.items

    if index >= 0 && index < TEXTURE_SLOT_MAX {
        self.items        += 1
        self.array[index]  = texture

        return true
    }

    return false
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
TEXTURE_FORMAT_COMPS := [Texture_Format]int {
    .TEXTURE_NONE = 0,
    .TEXTURE_RGB  = 3,
    .TEXTURE_RGBA = 4,
}

@(private)
TEXTURE_FORMAT := [Texture_Format]int {
    .TEXTURE_NONE = 0,
    .TEXTURE_RGB  = gl.RGB,
    .TEXTURE_RGBA = gl.RGBA,
}
