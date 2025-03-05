package pax2d

import "core:log"
import "core:strings"
import "core:mem"

import stbi "vendor:stb/image"

//
// Types
//

Image_Format :: enum
{
    NONE, RGB, RGBA,
}

Image :: struct
{
    format: Image_Format,
    size:   [2]int,
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

    data := stbi.load(clone, &width, &height, &chann, 0)

    if data == nil {
        log.errorf("Image: Unable to read image from file")

        return {}, false
    }

    length := width * height * chann
    format := Image_Format.NONE

    switch chann {
        case 3: format = .RGB
        case 4: format = .RGBA
    }

    if format == .NONE { return {}, false }

    value.format = format
    value.size.x = int(width)
    value.size.y = int(height)
    value.data   = data[:length]

    return value, true
}

image_destroy :: proc(self: ^Image)
{
    stbi.image_free(&self.data[0])
}
