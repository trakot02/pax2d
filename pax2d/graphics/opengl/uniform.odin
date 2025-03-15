package opengl

//
// Values
//

UNIFORM_SLOT_MAX :: int(8)

//
// Types
//

Uniform_Slot :: struct
{
    texture: ^Texture,
    sampler: ^Sampler,
}

Uniform_Slots :: struct
{
    array: [UNIFORM_SLOT_MAX]Uniform_Slot,
    items: int,
}

//
// Procs
//

uniform_slots_clear :: proc(self: ^Uniform_Slots)
{
    self.items = 0
}

uniform_slots_index_of :: proc(self: ^Uniform_Slots, value: Uniform_Slot) -> (int, bool)
{
    for index in 0 ..< self.items {
        other := self.array[index]

        if other.texture.handle == value.texture.handle &&
           other.sampler.handle == value.sampler.handle {
            return index, true
        }
    }

    return 0, false
}

uniform_slots_add :: proc(self: ^Uniform_Slots, value: Uniform_Slot) -> bool
{
    index := self.items

    if index >= 0 && index < len(self.array) {
        self.items        += 1
        self.array[index]  = value

        return true
    }

    return false
}
