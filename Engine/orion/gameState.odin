package orion

import "core:fmt"

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
        DEBUG = debug,
    }
    return game
}

// Initialize global game state
GAME := create_game(true)