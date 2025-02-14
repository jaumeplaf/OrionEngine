package orion

import "core:fmt"
import "core:c"
import "core:time"
import m "core:math/linalg/glsl"
import "base:runtime"
import "vendor:glfw"

//Event callbacks

keyCallback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
    context = runtime.default_context()
    if action == glfw.PRESS {
        switch key {
        case glfw.KEY_ESCAPE:
            GAME.EXIT = true
        case glfw.KEY_W:
            GAME.INPUT.FORWARD = true
            if GAME.DEBUG {
                fmt.println("W pressed")
            }
        case glfw.KEY_S:
            GAME.INPUT.BACKWARD = true
            if GAME.DEBUG {
                fmt.println("S pressed")
            }
        case glfw.KEY_A:
            GAME.INPUT.LEFT = true
            if GAME.DEBUG {
                fmt.println("A pressed")
            }
        case glfw.KEY_D:
            GAME.INPUT.RIGHT = true
            if GAME.DEBUG {
                fmt.println("D pressed")
            }
        case glfw.KEY_SPACE:
            GAME.INPUT.JUMP = true
            if GAME.DEBUG {
                fmt.println("Space pressed")
            }
        case glfw.KEY_LEFT_SHIFT:
            GAME.INPUT.SPRINT = true
            if GAME.DEBUG {
                fmt.println("Shift pressed")
            }
        case glfw.KEY_LEFT_CONTROL:
            GAME.INPUT.CROUCH = true
            if GAME.DEBUG {
                fmt.println("Ctrl pressed")
            }
        }
    } else if action == glfw.RELEASE {
        switch key {
        case glfw.KEY_W:
            GAME.INPUT.FORWARD = false
            if GAME.DEBUG {
                fmt.println("W released")
            }
        case glfw.KEY_S:
            GAME.INPUT.BACKWARD = false
            if GAME.DEBUG {
                fmt.println("S released")
            }
        case glfw.KEY_A:
            GAME.INPUT.LEFT = false
            if GAME.DEBUG {
                fmt.println("A released")
            }
        case glfw.KEY_D:
            GAME.INPUT.RIGHT = false
            if GAME.DEBUG {
                fmt.println("D released")
            }
        case glfw.KEY_SPACE:
            GAME.INPUT.JUMP = false
            if GAME.DEBUG {
                fmt.println("Space released")
            }
        case glfw.KEY_LEFT_SHIFT:
            GAME.INPUT.SPRINT = false
            if GAME.DEBUG {
                fmt.println("Shift released")
            }
        case glfw.KEY_LEFT_CONTROL:
            GAME.INPUT.CROUCH = false
            if GAME.DEBUG {
                fmt.println("Ctrl released")
            }
        }
    }
}

mouseCallback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
    context = runtime.default_context()
    if action == glfw.PRESS {
        switch button {
        case glfw.MOUSE_BUTTON_LEFT:
            GAME.INPUT.LEFT_CLICK = true
            if GAME.DEBUG {
                fmt.println("Left mouse button clicked!")
            }
        case glfw.MOUSE_BUTTON_MIDDLE:
            GAME.INPUT.MIDDLE_CLICK = true
            if GAME.DEBUG {
                fmt.println("Middle mouse button clicked!")
            }
        case glfw.MOUSE_BUTTON_RIGHT:
            GAME.INPUT.RIGHT_CLICK = true
            if GAME.DEBUG {
                fmt.println("Right mouse button clicked!")
            }
        }
    } else if action == glfw.RELEASE {
        switch button {
        case glfw.MOUSE_BUTTON_LEFT:
            GAME.INPUT.LEFT_CLICK = false
            if GAME.DEBUG {
                fmt.println("Left mouse button released!")
            }
        case glfw.MOUSE_BUTTON_MIDDLE:
            GAME.INPUT.MIDDLE_CLICK = false
            if GAME.DEBUG {
                fmt.println("Middle mouse button released!")
            }
        case glfw.MOUSE_BUTTON_RIGHT:
            GAME.INPUT.RIGHT_CLICK = false
            if GAME.DEBUG {
                fmt.println("Right mouse button released!")
            }
        }
    }
}

cursorPositionCallback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
    context = runtime.default_context()
	GAME.INPUT.MOUSE_POS = [2]f64{xpos, ypos}
	if GAME.DEBUG {
        fmt.println("Mouse moved: ", "x-", xpos, "y-", ypos)
    }
}

scrollCallback :: proc "c" (window: glfw.WindowHandle, xoffset, yoffset: f64) {
	context = runtime.default_context()
    if yoffset > 0 {
        GAME.INPUT.SCROLL_UP = true
        GAME.INPUT.SCROLL_DOWN = false
    } 
    else if yoffset < 0 {
        GAME.INPUT.SCROLL_UP = false
        GAME.INPUT.SCROLL_DOWN = true
    }
    else {
        GAME.INPUT.SCROLL_UP = false
        GAME.INPUT.SCROLL_DOWN = false
    }
	if GAME.DEBUG {
        fmt.println("Scrolling: ", "x-", xoffset, "y-", yoffset)
    }
}

framebufferSizeCallback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	context = runtime.default_context()
	GAME.RATIO = getAspectRatio_i32(width, height)
	GAME.RESIZE = true
	if GAME.DEBUG {
        fmt.println("Framebuffer resized: ", "w-", width, "h-", height)
    }
    defer GAME.RESIZE = false
}