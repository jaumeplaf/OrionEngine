package orion

import "core:fmt"
import m "core:math/linalg/glsl"

transformCreate :: proc(manager: ^ComponentManager, id: entity_id, position: m.vec3, rotation: m.vec3, scale: m.vec3){
    manager.transforms[id] = Transform{
        position = position,
        rotation = rotation,
        scale = scale,
    }
}

setTransform :: proc(scene: ^Scene, id: entity_id, position: m.vec3, rotation: m.vec3, scale: m.vec3){
    scene.components.transforms[id] = Transform{
        position = position,
        rotation = rotation,
        scale = scale,
    }
}

transformDestroy :: proc(manager: ^ComponentManager, id: entity_id) {
    delete_key(&manager.transforms, id)
}