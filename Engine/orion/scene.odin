package orion

import "core:fmt"
import "core:encoding/json"

Scene :: struct {
    name : string,
    entities : ^EntityManager,
    components : ^ComponentManager,
    //events : ^EventManager
    shaders : ^ShaderManager,
}

initScene :: proc(name: string) -> ^Scene {
    if GAME.DEBUG {
        fmt.println("Initializing scene")
    }
    scene := new(Scene)
    scene.name = name
    if GAME.DEBUG {
        fmt.println("Initializing entity manager")
    }
    scene.entities = initEntityManager()
    if GAME.DEBUG {
        fmt.println("Initializing component manager")
    }
    scene.components = initComponentManager()
    //scene.events = initEventManager()
    if GAME.DEBUG {
        fmt.println("Initializing shader manager")
    }
    scene.shaders = initShaderManager()
    //initializeEvents(scene.events, scene.entities, scene.components)
    if GAME.DEBUG {
        fmt.println("Setting active scene")
    }
    //Set active scene, for now there is only one scene
    GAME.ACTIVE_SCENE = scene
    if GAME.DEBUG {
        fmt.println("Initializing camera")
    }
    //IT LOOKS LIKE IT CRASHES AROUND HERE, EITHER THE CAMERA OR VIEW/PROJ MATRICES
    initCamera(70, .fps, 0.1, 1000)
    if GAME.DEBUG {
        fmt.println("Camera initialized")
    }

    return scene
}