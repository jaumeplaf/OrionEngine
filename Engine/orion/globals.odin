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
    GL_MAJOR_VERSION : i32,
    GL_MINOR_VERSION : i32,

    WINDOW : glfw.WindowHandle,
    MOUSE_POS: m.vec2,
    
    //Event callbacks
    RATIO : f32,
    EXIT : bool,
    RESIZE : bool,
    ACTIVE_SCENE: ^Scene,
}

//Initialize global game state
GAME := new(Game)
