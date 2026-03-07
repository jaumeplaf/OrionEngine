package orion

import "core:fmt"
import "core:c"
import "core:time"
import m "core:math/linalg/glsl"
import "base:runtime"
import "vendor:glfw"
import gl "vendor:OpenGL"

//Event callbacks

keyCallback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
    context = runtime.default_context()

    if action == glfw.PRESS {
        switch key {
        case glfw.KEY_0:
            swapActiveCamera()
        case glfw.KEY_ESCAPE:
            scene := GAME.ACTIVE_SCENE
            if scene != nil {
                if cam, ok := scene.components.cameras[GAME.ACTIVE_CAMERA]; ok && cam.style == .editor {
                    GAME.INPUT.RIGHT_CLICK = false
                    applyCursorModeForCamera(cam.style)
                    return
                }
            }

            if GAME.INPUT.MOUSE_LOOK_ACTIVE {
                glfw.SetInputMode(GAME.WINDOW, glfw.CURSOR, glfw.CURSOR_NORMAL)
                GAME.INPUT.MOUSE_LOOK_ACTIVE = false
                GAME.INPUT.MOUSE_INITIALIZED = false
                GAME.INPUT.MOUSE_DELTA = [2]f64{0, 0}
                GAME.INPUT.MOUSE_SKIP_NEXT_DELTA = true
            } else {
                GAME.EXIT = true
            }
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
        scene := GAME.ACTIVE_SCENE
        if scene != nil {
            if cam, ok := scene.components.cameras[GAME.ACTIVE_CAMERA]; ok {
                if cam.style == .fps && !GAME.INPUT.MOUSE_LOOK_ACTIVE {
                    applyCursorModeForCamera(.fps)
                }

                if cam.style == .editor && button == glfw.MOUSE_BUTTON_RIGHT {
                    GAME.INPUT.RIGHT_CLICK = true
                    applyCursorModeForCamera(.editor)
                }
            }
        }

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
        scene := GAME.ACTIVE_SCENE
        if scene != nil {
            if cam, ok := scene.components.cameras[GAME.ACTIVE_CAMERA]; ok {
                if cam.style == .editor && button == glfw.MOUSE_BUTTON_RIGHT {
                    GAME.INPUT.RIGHT_CLICK = false
                    applyCursorModeForCamera(.editor)
                }
            }
        }

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

    if !GAME.INPUT.MOUSE_LOOK_ACTIVE {
        GAME.INPUT.LAST_MOUSE_POS = GAME.INPUT.MOUSE_POS
        GAME.INPUT.MOUSE_INITIALIZED = true
        return
    }

    if GAME.INPUT.MOUSE_WARMUP_FRAMES > 0 {
        GAME.INPUT.LAST_MOUSE_POS = GAME.INPUT.MOUSE_POS
        GAME.INPUT.MOUSE_WARMUP_FRAMES -= 1
        GAME.INPUT.MOUSE_INITIALIZED = true
        return
    }

    if !GAME.INPUT.MOUSE_INITIALIZED {
        GAME.INPUT.LAST_MOUSE_POS = GAME.INPUT.MOUSE_POS
        GAME.INPUT.MOUSE_INITIALIZED = true
        return
    }

    delta_x := xpos - GAME.INPUT.LAST_MOUSE_POS[0]
    delta_y := ypos - GAME.INPUT.LAST_MOUSE_POS[1]

    if GAME.INPUT.MOUSE_SKIP_NEXT_DELTA {
        GAME.INPUT.MOUSE_SKIP_NEXT_DELTA = false
        GAME.INPUT.LAST_MOUSE_POS = GAME.INPUT.MOUSE_POS
        return
    }

    spike_threshold: f64 = 200
    if m.abs_f64(delta_x) > spike_threshold || m.abs_f64(delta_y) > spike_threshold {
        GAME.INPUT.LAST_MOUSE_POS = GAME.INPUT.MOUSE_POS
        return
    }

    GAME.INPUT.MOUSE_DELTA[0] += delta_x
    GAME.INPUT.MOUSE_DELTA[1] += delta_y
    GAME.INPUT.LAST_MOUSE_POS = GAME.INPUT.MOUSE_POS

	if GAME.DEBUG {
        //fmt.println("Mouse moved: ", "x-", xpos, "y-", ypos)
    }
}

scrollCallback :: proc "c" (window: glfw.WindowHandle, xoffset, yoffset: f64) {
	context = runtime.default_context()
    GAME.INPUT.SCROLL_DELTA += yoffset
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
    gl.Viewport(0, 0, width, height)
	GAME.RESIZE = true

    if GAME.ACTIVE_SCENE != nil {
        scene := GAME.ACTIVE_SCENE
        if cam, ok := scene.components.cameras[GAME.ACTIVE_CAMERA]; ok {
            calculateProjectionMatrix(&cam)
            scene.components.cameras[GAME.ACTIVE_CAMERA] = cam
            updateProjectionMatrix()
        }
    }

	if GAME.DEBUG {
        fmt.println("Framebuffer resized: ", "w-", width, "h-", height)
    }
    defer GAME.RESIZE = false
}