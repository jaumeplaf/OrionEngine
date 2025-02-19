package orion

import "core:fmt"
import "vendor:glfw"

gameLoop :: proc(scene: ^Scene) { 
    for !glfw.WindowShouldClose(GAME.WINDOW) && GAME.EXIT == false {
        drawSystem(scene)
        //tick(GAME.DEBUG)
    }
}

tick :: proc(debug: bool = false){
    if(debug){
        fmt.println("Tick")
    }
    scene := GAME.ACTIVE_SCENE
    cam := scene.components.cameras[GAME.ACTIVE_CAMERA]
    updateCameraPosition(&cam)
}