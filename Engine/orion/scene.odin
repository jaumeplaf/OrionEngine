package orion

import "core:fmt"
import m "core:math/linalg/glsl"
import "core:encoding/json"


Scene :: struct {
    name : string,
    entities : ^EntityManager,
    components : ^ComponentManager,
    //events : ^EventManager
    shaders : ^ShaderManager,
}

initScene :: proc(name: string, fov: f32) -> ^Scene {
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
    fps_id := initCamera(fov, .fps, 0.01, 10000, m.vec3{5,1.7,10})
    editor_id := initCamera(fov, .editor, 0.01, 10000, m.vec3{5,1.7,10})

    GAME.FPS_CAMERA = fps_id
    GAME.EDITOR_CAMERA = editor_id
    GAME.ACTIVE_CAMERA = fps_id

    cam := &scene.components.cameras[GAME.ACTIVE_CAMERA]
    setProjectionMatrix(cam)
    setViewMatrix(cam)
    applyCursorModeForCamera(cam.style)
    if GAME.DEBUG {
        fmt.println("---DEBUG CAM:", scene.components.cameras[GAME.ACTIVE_CAMERA])
    }
    if GAME.DEBUG {
        fmt.println("Camera initialized")
    }

    return scene
}