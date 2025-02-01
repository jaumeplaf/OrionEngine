package orion

import "core:fmt"

EntityManager :: struct {
    alive : map[entity_id]bool,
    next_id : entity_id
    //can implement a list of freed IDs to reuse, in case of particles or other short-lived entities
}

ComponentManager :: struct {
    transforms : map[entity_id]Transform,
    static_meshes : map[entity_id]StaticMesh,
    //lights : map[entity_id]Light,
    cameras : map[entity_id]Camera,
    players : map[entity_id]Player
}

EventManager :: struct {
    events : map[^bool]bool
}
