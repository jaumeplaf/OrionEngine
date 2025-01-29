package base

import "core:fmt"
import "vendor:glfw"

//OpenGL version declaration
GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 1

GAME_WINDOW : glfw.WindowHandle

//Event callbacks
ASPECT_RATIO : f32
EXIT_APPLICATION : bool = false
RESIZE_WINDOW : bool = false