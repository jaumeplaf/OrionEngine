package orion

import "core:fmt"
import "vendor:glfw"

gameLoop :: proc(objects: ^[]StaticMesh) { 
    for !glfw.WindowShouldClose(GAME_WINDOW) && EXIT_APPLICATION == false {
        draw(objects)

    }
}

tick :: proc(debug: bool = false){
    if(debug){
        fmt.println("Tick")
    }
}