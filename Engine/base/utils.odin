package base

import "core:fmt"

getAspectRatio :: proc(width: f32, height: f32) -> f32 {
    return width / height
}

getAspectRatio_i32 :: proc(width: i32, height: i32) -> f32 {
    return f32(width) / f32(height)
}