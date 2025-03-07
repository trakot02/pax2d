package opengl

import gl "vendor:OpenGL"

//
// Values
//

SAMPLER_SLOT_MAX :: int(8)

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

Sampler :: struct
{
    handle: int,
}

Sampler_Bundle_Array :: [SAMPLER_SLOT_MAX]^Sampler

Sampler_Bundle :: struct
{
    array: Sampler_Bundle_Array,
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

sampler_bind :: proc(self: ^Sampler, slot: int = 0) -> bool
{
    if slot < 0 || slot >= SAMPLER_SLOT_MAX {
        return false
    }

    gl.BindSampler(u32(slot), u32(self.handle))

    return true
}

sampler_unbind :: proc()
{
    for slot in 0 ..< SAMPLER_SLOT_MAX {
        gl.BindSampler(u32(slot), 0)
    }
}

sampler_set_filtering :: proc(self: ^Sampler, filter: Sampler_Filter, mode: Sampler_Filter_Mode) -> bool
{
    filter_value := SAMPLER_FILTER[filter]
    mode_value   := SAMPLER_FILTER_MODE[mode]

    if filter == .FILTER_NONE || mode == .MODE_NONE {
        return false
    }

    gl.SamplerParameteri(u32(self.handle),
        u32(filter_value), i32(mode_value))

    return true
}

sampler_set_wrapping :: proc(self: ^Sampler, axis: Sampler_Wrap_Axis, mode: Sampler_Wrap_Mode) -> bool
{
    axis_value := SAMPLER_WRAP_AXIS[axis]
    mode_value := SAMPLER_WRAP_MODE[mode]

    if axis == .AXIS_NONE || mode == .MODE_NONE {
        return false
    }

    gl.SamplerParameteri(u32(self.handle),
        u32(axis_value), i32(mode_value))

    return true
}

sampler_bundle_clear :: proc(self: ^Sampler_Bundle)
{
    self.items = 0
}

sampler_bundle_index_of :: proc(self: ^Sampler_Bundle, sampler: ^Sampler) -> int
{
    for index in 0 ..< self.items {
        value := self.array[index]

        if value.handle == sampler.handle {
            return index
        }
    }

    return SAMPLER_SLOT_MAX
}

sampler_bundle_add :: proc(self: ^Sampler_Bundle, sampler: ^Sampler) -> bool
{
    index := self.items

    if index >= 0 && index < SAMPLER_SLOT_MAX {
        self.items        += 1
        self.array[index]  = sampler

        return true
    }

    return false
}

sampler_bundle_bind :: proc(self: ^Sampler_Bundle)
{
    for index in 0 ..< self.items {
        sampler_bind(self.array[index], index)
    }
}

sampler_bundle_unbind :: proc()
{
    sampler_unbind()
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
