package orion

import "core:fmt"
import m "core:math/linalg/glsl"

//Create transform component on an entity
createTransform :: proc(scene: ^Scene, id: entity_id, 
    pos: m.vec3, rot_axis: m.vec3, rot_rads: f32, scale: m.vec3){
    scene.components.transforms[id] = Transform{
        position = pos,
        rotation_axis = rot_axis,
        rotation = rot_rads,
        scale = scale,
    }
    updateModelMatrix(scene, id)
}

setTransform :: proc(scene: ^Scene, id: entity_id, 
    pos: m.vec3, rot_axis: m.vec3, rot: f32, scal: m.vec3){
        transform := scene.components.transforms[id]
        transform.position = pos
        transform.rotation_axis = rot_axis
        transform.rotation = rot
        transform.scale = scal
        scene.components.transforms[id] = transform
        updateModelMatrix(scene, id)
}

translate :: proc(scene: ^Scene, id: entity_id, translation: m.vec3){
    if transform, ok := scene.components.transforms[id]; ok {
        new_translate := transform.position + translation
        setTransform(scene, id, new_translate, transform.rotation_axis, transform.rotation, transform.scale)
        updateModelMatrix(scene, id)
    }
}

rotate :: proc(scene: ^Scene, id: entity_id, axis: m.vec3, degs: f32){
    if transform, ok := scene.components.transforms[id]; ok {
        setTransform(scene, id, transform.position, axis, degs, transform.scale)
        updateModelMatrix(scene, id)
    }
}

transformDestroy :: proc(manager: ^ComponentManager, id: entity_id) {
    delete_key(&manager.transforms, id)
}