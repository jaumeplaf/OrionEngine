package orion

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"

initGL :: proc(width: i32, height: i32) {
    // Initialize GLFW (similar to WebGL canvas context creation)

    if glfw.Init() != true {
        fmt.eprintln("Failed to initialize GLFW")
        return
    }

    // Window hints (similar to WebGL context attributes)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    when ODIN_OS == .Darwin {  // Needed for macOS
        glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, 1)
    }

    // Create window (like creating a canvas element in WebGL)
    GAME.WINDOW = glfw.CreateWindow(width, height, "Orion", nil, nil)
    if GAME.WINDOW == nil {
        fmt.eprintln("Failed to create GLFW window")
        return
    }

    glfw.MakeContextCurrent(GAME.WINDOW)
    //Enable callbacks
	glfw.SetKeyCallback(GAME.WINDOW, keyCallback)
	glfw.SetMouseButtonCallback(GAME.WINDOW, mouseCallback)
    glfw.SetScrollCallback(GAME.WINDOW, scrollCallback)
	glfw.SetCursorPosCallback(GAME.WINDOW, cursorPositionCallback)
	glfw.SetFramebufferSizeCallback(GAME.WINDOW, framebufferSizeCallback)

    // Load OpenGL functions (automatic in WebGL, explicit here)
    gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
}