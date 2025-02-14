package orion

import "core:fmt"
import m "core:math/linalg/glsl"
import "vendor:glfw"

//Redeclarations
GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 1

// Initialize global game state
GAME := create_game(false)

//Manage game state globally
Game :: struct {
    GL_VERSION : [2]i32,
    WINDOW : glfw.WindowHandle,
    RATIO : f32,
    EXIT : bool,
    RESIZE : bool,
    ACTIVE_SCENE: ^Scene,
    INPUT: ^Input,
    MODE: ^Mode,
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

// Specific behaviours based on game mode
Mode :: enum {
    EDITOR,
    GAMEPLAY,
}


create_game :: proc(debug: bool) -> ^Game {
    game := new(Game)
    game^ = Game{
        GL_VERSION = [2]i32{GL_MAJOR_VERSION, GL_MINOR_VERSION},
        WINDOW = nil,
        RATIO = 0.0,
        EXIT = false,
        RESIZE = false,
        ACTIVE_SCENE = nil,
        INPUT = new(Input),
        MODE = new(Mode),
        DEBUG = debug,
    }
    return game
}

