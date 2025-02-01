package orion


import "core:fmt"
import "core:time"
import "vendor:glfw"

//Game lifecycle

//Combined loop
gameLoop :: proc(entities : ^EntityManager, components : ^ComponentManager, events : ^EventManager) {

    for !glfw.WindowShouldClose(GAME.WINDOW) && !GAME.EXIT {
        //Logic loop
        tick(entities, components, events) 
        //Draw loop
        draw(entities, components, events) 
    }
    //Destroy window & context
    cleanup() 
}

//Logic loop
tick :: proc(entities : ^EntityManager, components : ^ComponentManager, events : ^EventManager) {
    player := components.players[0]
    calcTime()
    updatePlayerPosition(&player)
}

//Calculate time variables
calcTime :: proc(){
    debug := false
    GAME.PREV_TIME = GAME.NOW_TIME
    GAME.NOW_TIME = time.now()

    GAME.DELTA_TIME = -time.duration_milliseconds(time.diff(GAME.NOW_TIME, GAME.PREV_TIME))
    GAME.GAME_TIME = -time.duration_milliseconds(time.diff(GAME.NOW_TIME, GAME.START_TIME))

    if(debug){
        fmt.printf("DeltaTime: %f\n", GAME.DELTA_TIME)
        fmt.printf("GameTime: %f\n", GAME.GAME_TIME)
    }
}