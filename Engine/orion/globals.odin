package orion

import "core:fmt"
import m "core:math/linalg/glsl"
import "vendor:glfw"

//Redeclarations
GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 1

//Game state struct
Game :: struct {
    //OpenGL version declaration
    GL_VERSION : [2]i32,

    WINDOW : glfw.WindowHandle,
    
    //Event callbacks
    RATIO : f32,
    EXIT : bool,
    RESIZE : bool,
    ACTIVE_SCENE: ^Scene,
    INPUT: ^Input,

    DEBUG: bool,

}

Input :: struct {
    LEFT_CLICK : bool,
    MIDDLE_CLICK : bool,
    RIGHT_CLICK : bool,
    SCROLL_UP : bool,
    SCROLL_DOWN : bool,
    FORWARD : bool,
    BACKWARD : bool,
    LEFT : bool,
    RIGHT : bool,
    JUMP : bool,
    SPRINT : bool,
    CROUCH : bool,
    MOUSE_POS: [2]f64,
}
