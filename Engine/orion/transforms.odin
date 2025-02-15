package orion

import "core:fmt"
import m "core:math/linalg/glsl"

//Create transform component on an entity
setTransform :: proc(scene: ^Scene, id: entity_id, 
    position: m.vec3, rot_axis: m.vec3, rot_rads: f32, scale: m.vec3){
    scene.components.transforms[id] = Transform{
        position = position,
        rotation_axis = rot_axis,
        rotation_rads = rot_rads,
        scale = scale,
    }
    if mesh, ok  := scene.components.meshes[id]; ok {
        calculateModelMatrix(&scene.components.meshes[id], position, rot_axis, rot_rads, scale)
        setModelMatrix(scene, id)
    }
}

transformDestroy :: proc(manager: ^ComponentManager, id: entity_id) {
    delete_key(&manager.transforms, id)
}