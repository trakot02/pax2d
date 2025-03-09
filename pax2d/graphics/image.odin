package graphics

import "core:log"
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

image_from_file :: proc(filename: string) -> (Image, bool)
{
    // TODO(gio): Read through odin's os package

    clone, error := strings.clone_to_cstring(filename,
        context.temp_allocator)

    if error != nil {
        log.errorf("Image: Unable to clone filename to c-string")

        return {}, false
    }

    defer mem.free_all(context.temp_allocator)

    value := Image {}

    width  := i32 {}
    height := i32 {}
    chann  := i32 {}

    stbi.set_flip_vertically_on_load(1)

    data := stbi.load(clone, &width, &height, &chann, 0)

    if data == nil {
        log.errorf("Image: Unable to read image from file")

        return {}, false
    }

    format := Image_Format.IMAGE_NONE
    length := width * height * chann

    switch chann {
        case 3: format = .IMAGE_RGB
        case 4: format = .IMAGE_RGBA
    }

    if format == .IMAGE_NONE {
        return {}, false
    }

    value.format = format
    value.items  = {int(width), int(height)}
    value.data   = data[:length]

    return value, true
}

image_destroy :: proc(self: ^Image)
{
    stbi.image_free(&self.data[0])

    self.format = .IMAGE_NONE
    self.items  = {}
    self.data   = nil
}
