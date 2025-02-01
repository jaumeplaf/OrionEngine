package orion

import "core:fmt"
import "core:time"
import m "core:math/linalg/glsl"
import "vendor:glfw"

//OpenGL version declaration
GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 1



Game :: struct {

    WINDOW : glfw.WindowHandle,

    //Event callbacks
    RATIO : f32,
    EXIT : bool,
    RESIZE : bool,

    UP : m.vec3,

    ACTIVE_CAMERA : entity_id,
    START_TIME : time.Time,
    NOW_TIME : time.Time,
    PREV_TIME : time.Time,
    GAME_TIME : f64,
    DELTA_TIME : f64
}

GAME := Game{
    EXIT = false,
    RESIZE = false,
    UP = m.vec3{0,1,0}
}
