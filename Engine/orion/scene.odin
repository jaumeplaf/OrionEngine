package orion

import "core:fmt"

Scene :: struct {
    name : string,
    entities : ^EntityManager,
    components : ^ComponentManager,
    //events : ^EventManager
}

initScene :: proc(name: string, entities: ^EntityManager, components: ^ComponentManager /*, events : ^EventManager*/) -> Scene {
    scene := Scene{}
    scene.name = name
    scene.entities = entities
    scene.components = components
    //scene.events = events

    //initializeEvents(scene.events, scene.entities, scene.components)

    return scene
}