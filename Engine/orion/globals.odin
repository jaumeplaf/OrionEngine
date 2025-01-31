package orion

import "core:fmt"
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
        
}

GAME := Game{}
