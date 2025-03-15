package graphics

import "core:log"
import "core:os"
import "core:strings"
import "core:mem"

import stbi "vendor:stb/image"

//
// Types
//

Image_Format :: enum
{
    IMAGE_NONE,
    IMAGE_RGB,
    IMAGE_RGBA,
}

Image :: struct
{
    format: Image_Format,
    bytes:  int,
    items:  [2]int,
    data:   []byte,
}

//
// Procs
//

image_make_from_file :: proc(filename: string, allocator := context.allocator) -> (Image, bool)
{
    value := Image {}
    state := image_read_from_file(&value, filename, allocator)

    return value, state
}

image_destroy :: proc(self: ^Image)
{
    stbi.image_free(&self.data[0])

    self.format = .IMAGE_NONE
    self.bytes  = 0
    self.items  = {}
    self.data   = nil
}

image_read_from_file :: proc(self: ^Image, filename: string, allocator := context.allocator) -> bool
{
    bytes, state := os.read_entire_file(filename, allocator)

    if state == false {
        log.errorf("Image: Unable to read file")

        return false
    }

    defer delete(bytes)

    length := len(bytes)
    width  := i32 {}
    height := i32 {}
    chann  := i32 {}

    // stbi.set_flip_vertically_on_load(1)

    image := stbi.load_from_memory(&bytes[0], i32(length), &width, &height, &chann, 0)

    if image == nil {
        log.errorf("Image: Unable to parse image")

        return false
    }

    self.format = .IMAGE_NONE

    switch chann {
        case 3: self.format = .IMAGE_RGB
        case 4: self.format = .IMAGE_RGBA
    }

    if self.format == .IMAGE_NONE {
        log.errorf("Image: Format not supported")

        return false
    }

    self.bytes   = int(width * height * chann)
    self.items.x = int(width)
    self.items.y = int(height)
    self.data    = image[0:self.bytes]

    return true
}
