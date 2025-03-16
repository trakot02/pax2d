package opengl

import gl "vendor:OpenGL"

//
// Values
//

TEXTURE_SLOT_MAX :: int(8)

//
// Types
//

Sampler_Filter :: enum
{
    FILTER_NONE,
    FILTER_MIN,
    FILTER_MAG,
}

Sampler_Filter_Mode :: enum
{
    MODE_NONE,
    MODE_NEAREST,
    MODE_LINEAR,
}

Sampler_Wrap_Axis :: enum
{
    AXIS_NONE,
    AXIS_X,
    AXIS_Y,
}

Sampler_Wrap_Mode :: enum
{
    MODE_NONE,
    MODE_REPEAT,
}

Texture_Format :: enum
{
    TEXTURE_NONE,
    TEXTURE_RGB,
    TEXTURE_RGBA,
}

Sampler :: struct
{
    handle: int,
}

Texture :: struct
{
    handle: int,
    format: Texture_Format,
    stride: int,
    length: int,
}

Texture_Slot :: struct
{
    texture: ^Texture,
    sampler: ^Sampler,
}

Texture_Table :: struct
{
    array: [TEXTURE_SLOT_MAX]Texture_Slot,
    items: int,
}

//
// Procs
//

sampler_make :: proc() -> (Sampler, bool)
{
    handle := u32 {}
    value  := Sampler {}

    gl.GenSamplers(1, &handle)

    if handle != 0 {
        value.handle = int(handle)
    }

    return value, handle != 0
}

sampler_destroy :: proc(self: ^Sampler)
{
    handle := u32(self.handle)

    self.handle = 0

    gl.DeleteSamplers(1, &handle)
}

sampler_set_filtering :: proc(self: ^Sampler, filter: Sampler_Filter, mode: Sampler_Filter_Mode) -> bool
{
    filter_value := SAMPLER_FILTER[filter]
    mode_value   := SAMPLER_FILTER_MODE[mode]

    if filter == .FILTER_NONE || mode == .MODE_NONE {
        return false
    }

    gl.SamplerParameteri(u32(self.handle), u32(filter_value), i32(mode_value))

    return true
}

sampler_set_wrapping :: proc(self: ^Sampler, axis: Sampler_Wrap_Axis, mode: Sampler_Wrap_Mode) -> bool
{
    axis_value := SAMPLER_WRAP_AXIS[axis]
    mode_value := SAMPLER_WRAP_MODE[mode]

    if axis == .AXIS_NONE || mode == .MODE_NONE {
        return false
    }

    gl.SamplerParameteri(u32(self.handle), u32(axis_value), i32(mode_value))

    return true
}

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

texture_alloc :: proc(format: Texture_Format, limit: [2]int) -> (Texture, bool)
{
    value, state := texture_make()

    if state == false { return value, state }

    state = texture_realloc(&value, format, limit)

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
    self.stride = 0
    self.length = 0

    gl.DeleteTextures(1, &handle)
}

texture_get_size :: proc(self: ^Texture) -> [2]int
{
    size := [2]int {
        self.stride, self.length / self.stride,
    }

    return size
}

texture_realloc :: proc(self: ^Texture, format: Texture_Format, limit: [2]int) -> bool
{
    length := limit.x * limit.y
    stride := limit.x

    if format == .TEXTURE_NONE { return false }

    format_value := TEXTURE_FORMAT[format]

    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, u32(self.handle))

    defer gl.BindTexture(gl.TEXTURE_2D, 0)

    gl.TexImage2D(gl.TEXTURE_2D, 0, i32(format_value), i32(limit.x),
        i32(limit.y), 0, gl.RGB, gl.UNSIGNED_BYTE, nil)

    self.format = format
    self.stride = stride
    self.length = length

    return true
}

texture_write_all :: proc(self: ^Texture, format: Texture_Format, data: []byte) -> bool
{
    length := len(data)

    if format == .TEXTURE_NONE { return false }

    length /= TEXTURE_FORMAT_MULT[format]

    format_value := TEXTURE_FORMAT[format]

    if self.format != format { return false }
    if self.length != length { return false }

    size := texture_get_size(self)

    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, u32(self.handle))

    defer gl.BindTexture(gl.TEXTURE_2D, 0)

    gl.TexSubImage2D(gl.TEXTURE_2D, 0, 0, 0, i32(size.x), i32(size.y),
        u32(format_value), gl.UNSIGNED_BYTE, &data[0])

    return true
}

/*
   TODO(gio): reintroduce

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
*/

texture_normalize_coords :: proc(self: ^Texture, point: [2]f32) -> [2]f32
{
    size := texture_get_size(self)

    value := [2]f32 {
        point.x / f32(size.x),
        point.y / f32(size.y),
    }

    return value
}

texture_slot_is_equal :: proc(value: Texture_Slot, other: Texture_Slot) -> bool
{
    if value.texture == nil || other.texture == nil { return false }
    if value.sampler == nil || other.sampler == nil { return false }

    return value.texture.handle == other.texture.handle &&
           value.sampler.handle == other.sampler.handle
}

texture_table_clear :: proc(self: ^Texture_Table)
{
    self.items = 0
}

texture_table_add :: proc(self: ^Texture_Table, value: Texture_Slot) -> bool
{
    index := self.items

    if index >= 0 && index < len(self.array) {
        self.items        += 1
        self.array[index]  = value

        return true
    }

    return false
}

texture_table_index_of :: proc(self: ^Texture_Table, value: Texture_Slot) -> (int, bool)
{
    for index in 0 ..< self.items {
        other := self.array[index]

        if texture_slot_is_equal(value, other) {
            return index, true
        }
    }

    return 0, false
}

@(private)
SAMPLER_FILTER := [Sampler_Filter]int {
    .FILTER_NONE = 0,
    .FILTER_MIN  = gl.TEXTURE_MIN_FILTER,
    .FILTER_MAG  = gl.TEXTURE_MAG_FILTER,
}

@(private)
SAMPLER_FILTER_MODE := [Sampler_Filter_Mode]int {
    .MODE_NONE    = 0,
    .MODE_NEAREST = gl.NEAREST,
    .MODE_LINEAR  = gl.LINEAR,
}

@(private)
SAMPLER_WRAP_AXIS := [Sampler_Wrap_Axis]int {
    .AXIS_NONE = 0,
    .AXIS_X    = gl.TEXTURE_WRAP_S,
    .AXIS_Y    = gl.TEXTURE_WRAP_T,
}

@(private)
SAMPLER_WRAP_MODE := [Sampler_Wrap_Mode]int {
    .MODE_NONE   = 0,
    .MODE_REPEAT = gl.REPEAT,
}

@(private)
TEXTURE_FORMAT_MULT := [Texture_Format]int {
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
