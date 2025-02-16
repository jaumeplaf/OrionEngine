package orion

import "core:fmt"
import m "core:math/linalg/glsl"

//Create transform component on an entity
setTransform :: proc(scene: ^Scene, id: entity_id, 
    pos: m.vec3, rot_axis: m.vec3, rot_rads: f32, scale: m.vec3){
    scene.components.transforms[id] = Transform{
        position = pos,
        rotation_axis = rot_axis,
        rotation = rot_rads,
        scale = scale,
    }
    if mesh, ok  := scene.components.meshes[id]; ok {
        transform := scene.components.transforms[id]
        calculateModelMatrix(&mesh, transform.position, transform.rotation_axis, transform.rotation, transform.scale)
        setModelMatrix(scene, id)
    }
}

transform :: proc(scene: ^Scene, id: entity_id, 
    pos: m.vec3, rot_axis: m.vec3, rot: f32, scal: m.vec3){
        transform := scene.components.transforms[id]
        transform.position += pos
        transform.rotation_axis = rot_axis
        transform.rotation = rot
        transform.scale = scal
        scene.components.transforms[id] = transform
    if mesh, ok  := scene.components.meshes[id]; ok {
        calculateModelMatrix(&mesh, transform.position, transform.rotation_axis, transform.rotation, transform.scale)
        setModelMatrix(scene, id)
    }
}
//TODO: Updte just uning transform() and updating the specified parameter
translate :: proc(scene: ^Scene, id: entity_id, translation: m.vec3){
    if transform, ok := scene.components.transforms[id]; ok {
        transform.position += translation
        scene.components.transforms[id] = transform
        if mesh, ok  := scene.components.meshes[id]; ok {
            calculateModelMatrix(&scene.components.meshes[id], transform.position, transform.rotation_axis, transform.rotation, transform.scale)
            setModelMatrix(scene, id)
        }
    }
}

rotate :: proc(scene: ^Scene, id: entity_id, axis: m.vec3, degs: f32){
    if transform, ok := scene.components.transforms[id]; ok {
        transform.rotation_axis = axis
        transform.rotation = degs
        scene.components.transforms[id] = transform
        if mesh, ok  := scene.components.meshes[id]; ok {
            calculateModelMatrix(&scene.components.meshes[id], transform.position, transform.rotation_axis, transform.rotation, transform.scale)
            setModelMatrix(scene, id)
        }
    }
}

transformDestroy :: proc(manager: ^ComponentManager, id: entity_id) {
    delete_key(&manager.transforms, id)
}