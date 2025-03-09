package graphics

import malg "core:math/linalg"

//
// Types
//

View :: struct
{
    viewport: [4]int,

    point: [2]f32,
    scale: [2]f32,
    angle: f32,
}

view_get_matrix :: proc(self: ^View) -> matrix[4, 4]f32
{
    width  := f32(self.viewport.z)
    height := f32(self.viewport.w)
    ratio  := width / height

    trans := malg.matrix_ortho3d_f32(-ratio, ratio, -1, 1, 0, 1000)

    trans *= malg.matrix4_scale_f32({self.scale.x, self.scale.y, 0,})
    trans *= malg.matrix4_rotate_f32(self.angle, {0, 0, 1})
    trans *= malg.matrix4_translate_f32({-self.point.x, -self.point.y, 0})

    return trans
}
