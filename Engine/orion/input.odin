package orion

import "core:fmt"
import "core:c"
import "base:runtime"
import "vendor:glfw"
import "core:time"

//Event callbacks

keyCallback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
    context = runtime.default_context()
    if action == glfw.PRESS {
        switch key {
        case glfw.KEY_ESCAPE:
            GAME.EXIT = true
        case glfw.KEY_W:
            fmt.println("W pressed")
        case glfw.KEY_S:
            fmt.println("S pressed")
        case glfw.KEY_A:
            fmt.println("A pressed")
        case glfw.KEY_D:
            fmt.println("D pressed")
        case glfw.KEY_SPACE:
            fmt.println("Space pressed")
        case glfw.KEY_LEFT_SHIFT:
            fmt.println("Shift pressed")
        case glfw.KEY_LEFT_CONTROL:
            fmt.println("Ctrl pressed")
        }
    } else if action == glfw.RELEASE {
        switch key {
        case glfw.KEY_W:
            fmt.println("W released")
        case glfw.KEY_S:
            fmt.println("S released")
        case glfw.KEY_A:
            fmt.println("A released")
        case glfw.KEY_D:
            fmt.println("D released")
        case glfw.KEY_SPACE:
            fmt.println("Space released")
        case glfw.KEY_LEFT_SHIFT:
            fmt.println("Shift released")
        case glfw.KEY_LEFT_CONTROL:
            fmt.println("Ctrl released")
        }
    }
}

mouseCallback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
    context = runtime.default_context()
    if action == glfw.PRESS {
        switch button {
        case glfw.MOUSE_BUTTON_LEFT:
            fmt.println("Left mouse button clicked!")
        case glfw.MOUSE_BUTTON_MIDDLE:
            fmt.println("Middle mouse button clicked!")
        case glfw.MOUSE_BUTTON_RIGHT:
            fmt.println("Right mouse button clicked!")
            //Activate rotate camera around position + wasd controls
        }
    } else if action == glfw.RELEASE {
        switch button {
        case glfw.MOUSE_BUTTON_LEFT:
            fmt.println("Left mouse button released!")
        case glfw.MOUSE_BUTTON_MIDDLE:
            fmt.println("Middle mouse button released!")
        case glfw.MOUSE_BUTTON_RIGHT:
            fmt.println("Right mouse button released!")
        }
    }
}

cursorPositionCallback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
    context = runtime.default_context()
	
	//fmt.println("Mouse moved: ", "x-", xpos, "y-", ypos)
}

scrollCallback :: proc "c" (window: glfw.WindowHandle, xoffset, yoffset: f64) {
	context = runtime.default_context()
	fmt.println("Scrolling: ", "x-", xoffset, "y-", yoffset)
}

framebufferSizeCallback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	context = runtime.default_context()
	//fmt.println("Framebuffer resized: ", "w-", width, "h-", height)
	GAME.RATIO = getAspectRatio_i32(width, height)
	GAME.RESIZE = true //this initializes the RESIZE_WINDOW event	
}