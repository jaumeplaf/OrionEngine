package orion

import "core:fmt"
import "vendor:glfw"

gameLoop :: proc(scene: ^Scene) { 
    for !glfw.WindowShouldClose(GAME.WINDOW) && GAME.EXIT == false {
        drawSystem(scene)
    }
}

tick :: proc(debug: bool = false){
    if(debug){
        fmt.println("Tick")
    }
}