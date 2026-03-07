package orion

import "core:fmt"
import m "core:math/linalg/glsl"
import "vendor:glfw"

//Redeclarations
GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 1
MAX_SHADERS :: 4
MAX_ENTITIES :: 1024
DEBUG_MODE :: false

//Controls
SENSITIVITY :: 1.0
MOVE_SPEED :: 0.3
SPRINT_SPEED :: 2.0
CROUCH_SPEED_MULT :: 0.5
JUMP_VELOCITY :: 0.18
GRAVITY_ACCEL :: 0.012
EDITOR_SPEED_MIN :: 0.25
EDITOR_SPEED_MAX :: 4.0
EDITOR_SCROLL_STEP :: 0.1

// Global game state (initialized at runtime)
GAME: ^Game

//Manage game state globally
Game :: struct {
    GL_VERSION : [2]i32,
    WINDOW : glfw.WindowHandle,
    RATIO : f32,
    EXIT : bool,
    RESIZE : bool,
    ACTIVE_SCENE: ^Scene,
    ACTIVE_CAMERA: u32,
    FPS_CAMERA: u32,
    EDITOR_CAMERA: u32,
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
    SCROLL_DELTA : f64,
    FORWARD : bool,
    BACKWARD : bool,
    LEFT : bool,
    RIGHT : bool,
    JUMP : bool,
    SPRINT : bool,
    CROUCH : bool,
    MOUSE_POS: [2]f64,
    MOUSE_DELTA: [2]f64,
    LAST_MOUSE_POS: [2]f64,
    MOUSE_INITIALIZED: bool,
    MOUSE_LOOK_ACTIVE: bool,
    MOUSE_WARMUP_FRAMES: i32,
    MOUSE_SKIP_NEXT_DELTA: bool,
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

initGameState :: proc(debug: bool = DEBUG_MODE) {
    if GAME != nil {
        return
    }
    GAME = create_game(debug)
}

