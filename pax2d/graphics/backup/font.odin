package graphics

import "core:log"
import "core:os"
import "core:mem"

import stbf "vendor:stb/truetype"

//
// Values
//

FONT_HEIGHT_BASE :: f32(48)

//
// Types
//

Font :: struct
{
    info: stbf.fontinfo,
    data: []byte,
}

Font_Metrics :: struct
{
    height:   int,
    ascent:   int,
    line_gap: int,
}

Glyph_Metrics :: struct
{
    index:   int,
    advance: int,
    bounds:  [4]int,
}

font_make_from_file :: proc(filename: string, index := 0, allocator := context.allocator) -> (Font, bool)
{
    value := Font {}
    state := font_read_from_file(&value, filename, index, allocator)

    return value, state
}

font_destroy :: proc(self: ^Font)
{
    delete(self.data)

    self.info = {}
    self.data = nil
}

font_read_from_file :: proc(self: ^Font, filename: string, index := 0, allocator := context.allocator) -> bool
{
    bytes, state := os.read_entire_file(filename, allocator)

    if state == false {
        log.errorf("Font: Unable to read file")

        return false
    }

    offset := stbf.GetFontOffsetForIndex(&bytes[0], i32(index))

    if offset == -1 {
        log.errorf("Font: Unable to locate font at index %v", index)

        delete(bytes)

        return false
    }

    info := stbf.fontinfo {}

    if stbf.InitFont(&info, &bytes[0], offset) == false {
        log.errorf("Font: Unable to parse font at index %v", index)

        delete(bytes)

        return false
    }

    self.info = info
    self.data = bytes

    return true
}

font_get_scale_for_height :: proc(self: ^Font, height: f32) -> f32
{
    return stbf.ScaleForPixelHeight(&self.info, height)
}

font_find_index_for_symbol :: proc(self: ^Font, symbol: rune) -> int
{
    return int(stbf.FindGlyphIndex(&self.info, symbol))
}

font_get_metrics :: proc(self: ^Font) -> Font_Metrics
{
    value    := Font_Metrics {}
    ascent   := i32 {}
    descent  := i32 {}
    line_gap := i32 {}

    stbf.GetFontVMetrics(&self.info, &ascent, &descent, &line_gap)

    value.height   = int(ascent - descent)
    value.ascent   = int(ascent)
    value.line_gap = int(line_gap)

    return value
}

font_get_glyph_metrics_for_index :: proc(self: ^Font, index: int) -> (Glyph_Metrics, bool)
{
    value    := Glyph_Metrics {}
    advance  := i32 {}
    bounds_x := i32 {}
    bounds_y := i32 {}
    bounds_z := i32 {}
    bounds_w := i32 {}

    if index == 0 { return value, false }

    stbf.GetGlyphHMetrics(&self.info, i32(index), &advance, nil)

    stbf.GetGlyphBox(&self.info, i32(index), &bounds_x,
        &bounds_y, &bounds_z, &bounds_w)

    value.index   = int(index)
    value.advance = int(advance)

    bounds_z -= bounds_x
    bounds_w -= bounds_y

    value.bounds = {
        int(bounds_x), int(bounds_y),
        int(bounds_z), int(bounds_w),
    }

    return value, true
}

font_get_glyph_metrics_for_symbol :: proc(self: ^Font, symbol: rune) -> (Glyph_Metrics, bool)
{
    return font_get_glyph_metrics_for_index(self, font_find_index_for_symbol(self, symbol))
}

font_get_glyph_metrics_for_symbol_range :: proc(self: ^Font, first: rune, range: []Glyph_Metrics) -> int
{
    for &item, index in range {
        glyph, state := font_get_glyph_metrics_for_symbol(self,
            first + rune(index))

        if state == false { return index }

        item = glyph
    }

    return len(range)
}

font_get_glyph_buffer_size :: proc(self: ^Font, glyph: Glyph_Metrics, scale: f32) -> [2]int
{
    value := [2]int {}

    if glyph.index == 0 { return value }

    value.x = int(scale * f32(glyph.bounds.z))
    value.y = int(scale * f32(glyph.bounds.w))

    return value
}

font_get_glyph_buffer_length :: proc(self: ^Font, glyph: Glyph_Metrics, scale: f32) -> int
{
    size := font_get_glyph_buffer_size(self, glyph, scale)

    return size.x * size.y
}

font_write_glyph_to_buffer :: proc(self: ^Font, glyph: Glyph_Metrics, scale: f32, buffer: []byte) -> bool
{
    if glyph.index == 0 { return false }

    size   := font_get_glyph_buffer_size(self, glyph, scale)
    length := size.x * size.y

    if len(buffer) < length { return false }

    stbf.MakeGlyphBitmap(&self.info, &buffer[0], i32(size.x),
        i32(size.y), i32(size.x), scale, scale, i32(glyph.index))

    return true
}

font_write_glyphs_to_image :: proc(self: ^Font, glyphs: []Glyph_Metrics, height := FONT_HEIGHT_BASE, allocator := context.allocator) -> (Image, bool)
{
    value := Image {}
    scale := font_get_scale_for_height(self, height)

    glyph, state := glyphs_find_biggest(glyphs)

    if state == false { return value, state }

    glyph_size   := font_get_glyph_buffer_size(self, glyph, scale)
    glyph_length := glyph_size.x * glyph_size.y

    glyph_buffer, glyph_error := mem.alloc_bytes(glyph_length, 1,
        context.temp_allocator)

    if glyph_error != nil {
        log.errorf("Font: Unable to allocate memory for glyph")

        return {}, false
    }

    defer mem.free_all(context.temp_allocator)

    image_size   := glyph_size
    image_length := image_size.x * image_size.y

    image_buffer, image_error := mem.alloc_bytes(image_length, 1, allocator)

    if image_error != nil {
        log.errorf("Font: Unable to allocate memory for image")

        return {}, false
    }

    state = font_write_glyph_to_buffer(self, glyph, scale, glyph_buffer)

    if state == false {
        delete(image_buffer)

        return value, false
    }

    for row in 0 ..< glyph_size.y {
        for col in 0 ..< glyph_size.x {
            log.debugf("%v, %v", col, row)
        }
    }

    value.bytes   = image_length
    value.items.x = image_size.x
    value.items.y = image_size.y
    value.data    = image_buffer

    return value, true
}

glyphs_index_of_biggest :: proc(glyphs: []Glyph_Metrics) -> (int, bool)
{
    value := 0

    if len(glyphs) == 0 { return value, false }

    for item, index in glyphs {
        bounds := glyphs[index].bounds
        other  := item.bounds

        if bounds.z < other.z || bounds.w < other.w {
            value = index
        }
    }

    return value, true
}

glyphs_find_biggest :: proc(glyphs: []Glyph_Metrics) -> (Glyph_Metrics, bool)
{
    value        := Glyph_Metrics {}
    index, state := glyphs_index_of_biggest(glyphs)

    if state == true {
        value = glyphs[index]
    }

    return value, state
}
