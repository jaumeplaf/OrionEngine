package orion

import "core:fmt"
import m "core:math/linalg/glsl"

//Entity: game actor that has an ID, can have components and can be manipulated by systems
entity_id :: u32

EntityManager :: struct {
    alive : map[entity_id]bool,
    freed_ids: [dynamic]entity_id,
    next_id : entity_id,
}

initEntityManager :: proc() -> ^EntityManager {
    manager := new(EntityManager)
    manager.alive = make(map[entity_id]bool)
    manager.freed_ids = make([dynamic]entity_id)
    manager.next_id = 0

    return manager
}

//Manage entities
entityCreate :: proc(scene: ^Scene) -> entity_id {
    entities := scene.entities
    id: entity_id
    if len(entities.freed_ids) > 0 {
        id = pop(&entities.freed_ids)
    } else {
        id = entities.next_id
        entities.next_id += 1
    }
    entities.alive[id] = true

    return id
}

entityDestroy :: proc(scene: ^Scene, id: entity_id) {
    entities := scene.entities
    components := scene.components

    destroyComponent(components, id)
    delete_key(&entities.alive, id)
    append(&entities.freed_ids, id)
}