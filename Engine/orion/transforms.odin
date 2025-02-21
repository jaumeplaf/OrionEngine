package orion

import "core:fmt"
import m "core:math/linalg/glsl"

//Create transform component on an entity
createTransform :: proc(id: entity_id, 
    pos: m.vec3, rot_axis: m.vec3, rot_rads: f32, scale: m.vec3){
    scene := GAME.ACTIVE_SCENE
    scene.components.transforms[id] = Transform{
        position = pos,
        rotation_axis = rot_axis,
        rotation = rot_rads,
        scale = scale,
    }
    updateModelMatrix(id)
}

setTransform :: proc(id: entity_id, 
    pos: m.vec3, rot_axis: m.vec3, rot: f32, scal: m.vec3){
        scene := GAME.ACTIVE_SCENE
        transform := scene.components.transforms[id]
        transform.position = pos
        transform.rotation_axis = rot_axis
        transform.rotation = rot
        transform.scale = scal
        scene.components.transforms[id] = transform
        updateModelMatrix(id)
}

translate :: proc(id: entity_id, translation: m.vec3){
    scene := GAME.ACTIVE_SCENE
    if transform, ok := scene.components.transforms[id]; ok {
        new_translate := transform.position + translation
        setTransform(id, new_translate, transform.rotation_axis, transform.rotation, transform.scale)
        updateModelMatrix(id)
    }
}

rotate :: proc(id: entity_id, axis: m.vec3, degs: f32){
    scene := GAME.ACTIVE_SCENE
    if transform, ok := scene.components.transforms[id]; ok {
        setTransform(id, transform.position, axis, degs, transform.scale)
        updateModelMatrix(id)
    }
}

scale :: proc(id: entity_id, scale: m.vec3){
    scene := GAME.ACTIVE_SCENE
    if transform, ok := scene.components.transforms[id]; ok {
        setTransform(id, transform.position, transform.rotation_axis, transform.rotation, scale)
        updateModelMatrix(id)
    }
}

transformDestroy :: proc(id: entity_id) {
    components := GAME.ACTIVE_SCENE.components
    delete_key(&components.transforms, id)
}