package orion

import "core:fmt"
import "core:c"
import "core:time"
import m "core:math/linalg/glsl"
import "base:runtime"

// Backend-specific callbacks should map to these handlers.

handleKeyInput :: proc(key: RHI_Key, action: RHI_Input_Action, mods: i32) {
    context = runtime.default_context()
    uiKeyEvent(key, action, mods)

    if action == .Press {
        #partial switch key {
        case .K0:
            swapActiveCamera()
        case .Escape:
            GAME.EXIT = true
        case .W:
            GAME.INPUT.FORWARD = true
            if GAME.DEBUG { fmt.println("W pressed") }
        case .S:
            GAME.INPUT.BACKWARD = true
            if GAME.DEBUG { fmt.println("S pressed") }
        case .A:
            GAME.INPUT.LEFT = true
            if GAME.DEBUG { fmt.println("A pressed") }
        case .D:
            GAME.INPUT.RIGHT = true
            if GAME.DEBUG { fmt.println("D pressed") }
        case .Space:
            GAME.INPUT.JUMP = true
            if GAME.DEBUG { fmt.println("Space pressed") }
        case .LeftShift:
            GAME.INPUT.SPRINT = true
            if GAME.DEBUG { fmt.println("Shift pressed") }
        case .LeftControl:
            GAME.INPUT.CROUCH = true
            if GAME.DEBUG { fmt.println("Ctrl pressed") }
        case:
        }
    } else if action == .Release {
        #partial switch key {
        case .W:
            GAME.INPUT.FORWARD = false
            if GAME.DEBUG { fmt.println("W released") }
        case .S:
            GAME.INPUT.BACKWARD = false
            if GAME.DEBUG { fmt.println("S released") }
        case .A:
            GAME.INPUT.LEFT = false
            if GAME.DEBUG { fmt.println("A released") }
        case .D:
            GAME.INPUT.RIGHT = false
            if GAME.DEBUG { fmt.println("D released") }
        case .Space:
            GAME.INPUT.JUMP = false
            if GAME.DEBUG { fmt.println("Space released") }
        case .LeftShift:
            GAME.INPUT.SPRINT = false
            if GAME.DEBUG { fmt.println("Shift released") }
        case .LeftControl:
            GAME.INPUT.CROUCH = false
            if GAME.DEBUG { fmt.println("Ctrl released") }
        case:
        }
    }
}

handleMouseButtonInput :: proc(button: RHI_Mouse_Button, action: RHI_Input_Action) {
    context = runtime.default_context()
    uiMouseButton(button, action, GAME.INPUT.MOUSE_POS[0], GAME.INPUT.MOUSE_POS[1])

    if action == .Press {
        scene := GAME.ACTIVE_SCENE
        if scene != nil {
            if cam, ok := scene.components.cameras[GAME.ACTIVE_CAMERA]; ok {
                if cam.style == .fps && !GAME.INPUT.MOUSE_LOOK_ACTIVE {
                    applyCursorModeForCamera(.fps)
                }

                if cam.style == .editor && button == .Right {
                    GAME.INPUT.RIGHT_CLICK = true
                    applyCursorModeForCamera(.editor)
                }
            }
        }

        #partial switch button {
        case .Left:
            GAME.INPUT.LEFT_CLICK = true
            if GAME.DEBUG { fmt.println("Left mouse button clicked!") }
        case .Middle:
            GAME.INPUT.MIDDLE_CLICK = true
            if GAME.DEBUG { fmt.println("Middle mouse button clicked!") }
        case .Right:
            GAME.INPUT.RIGHT_CLICK = true
            if GAME.DEBUG { fmt.println("Right mouse button clicked!") }
        case:
        }
    } else if action == .Release {
        scene := GAME.ACTIVE_SCENE
        if scene != nil {
            if cam, ok := scene.components.cameras[GAME.ACTIVE_CAMERA]; ok {
                if cam.style == .editor && button == .Right {
                    GAME.INPUT.RIGHT_CLICK = false
                    applyCursorModeForCamera(.editor)
                }
            }
        }

        #partial switch button {
        case .Left:
            GAME.INPUT.LEFT_CLICK = false
            if GAME.DEBUG { fmt.println("Left mouse button released!") }
        case .Middle:
            GAME.INPUT.MIDDLE_CLICK = false
            if GAME.DEBUG { fmt.println("Middle mouse button released!") }
        case .Right:
            GAME.INPUT.RIGHT_CLICK = false
            if GAME.DEBUG { fmt.println("Right mouse button released!") }
        case:
        }
    }
}

handleCursorPositionInput :: proc(xpos, ypos: f64) {
    context = runtime.default_context()
	GAME.INPUT.MOUSE_POS = [2]f64{xpos, ypos}
    uiMouseMove(xpos, ypos)

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

handleScrollInput :: proc(xoffset, yoffset: f64) {
	context = runtime.default_context()
    uiScroll(xoffset, yoffset)
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

handleFramebufferResize :: proc(width, height: i32) {
	context = runtime.default_context()
	GAME.RATIO = getAspectRatio_i32(width, height)
    rhiSetViewport(0, 0, width, height)
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

handleTextInput :: proc(codepoint: rune) {
    context = runtime.default_context()
    uiTextInput(codepoint)
}