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
entityCreate :: proc(entities : ^EntityManager) -> entity_id {
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
    fmt.println("Destroying entity")
    entities := scene.entities
    fmt.println("entities fetched")
    components := scene.components
    fmt.println("components fetched")
    destroyComponents(components, id)
    fmt.printf("Entity %d destroyed\n", id)
    delete_key(&entities.alive, id)
    fmt.printf("Entity %d removed from alive list\n", id)
    append(&entities.freed_ids, id)
    fmt.printf("Entity %d added to freed list\n", id)
}