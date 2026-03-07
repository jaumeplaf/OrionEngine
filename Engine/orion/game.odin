package orion

import "core:fmt"
import "vendor:glfw"

gameLoop :: proc(scene: ^Scene) { 
    for !glfw.WindowShouldClose(GAME.WINDOW) && GAME.EXIT == false {
        glfw.PollEvents()
        tick()
        drawSystem(scene)
    }
}

tick :: proc(debug: bool = false){
    if(debug){
        fmt.println("Tick")
    }
    scene := GAME.ACTIVE_SCENE
    if cam, ok := scene.components.cameras[GAME.ACTIVE_CAMERA]; ok {
        if cam.style == .fps {
            updateCameraLookFPS(&cam)
        } else if cam.style == .editor && GAME.INPUT.RIGHT_CLICK {
            updateCameraLookFPS(&cam)
        }
        updateCameraPosition(&cam)
        scene.components.cameras[GAME.ACTIVE_CAMERA] = cam
        updateViewMatrix()
    }
}