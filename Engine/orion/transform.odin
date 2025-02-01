package orion

import "core:fmt"
import m "core:math/linalg/glsl"
import gl "vendor:OpenGL"

//Components
Transform :: struct {
    position, rotation, scale : m.vec3,
    model_matrix : m.mat4
}

//Initialize transform component with default values
componentTransform :: proc(manager : ^ComponentManager, id : entity_id){
    transform := Transform{}
    transform.position = m.vec3{0.0, 0.0, 0.0}
    transform.rotation = m.vec3{0.0, 0.0, 0.0}
    transform.scale = m.vec3{1.0, 1.0, 1.0}
    transform.model_matrix = m.identity(m.mat4)
    manager.transforms[id] = transform
}
//Initialize transform component with custom values
componentTransformInit :: proc(manager : ^ComponentManager, id : entity_id, position : m.vec3, rotation : f32, axis : m.vec3, scale : m.vec3){
    transform := Transform{}
    transform.model_matrix = m.identity(m.mat4)
    transform.position = position
    transform.rotation = rotation
    transform.scale = scale
    //Set model matrix
    transform.model_matrix = m.mat4Translate(transform.position) * m.mat4Scale(transform.scale)
    transform.model_matrix = transform.model_matrix * m.mat4Rotate(axis, m.radians_f32(rotation))

    manager.transforms[id] = transform
}

transformRotate :: proc(manager : ^ComponentManager, id : entity_id, rotation : f32, axis : m.vec3){
    transform := manager.transforms[id]
    transform.rotation = rotation
    //Set model matrix
    transform.model_matrix = transform.model_matrix * m.mat4Rotate(axis, m.radians_f32(rotation))

    manager.transforms[id] = transform
}

transformTranslateScale :: proc(manager : ^ComponentManager, id : entity_id, position : m.vec3, scale : m.vec3){
    transform := manager.transforms[id]
    transform.position = position
    transform.scale = scale
    //Set model matrix
    transform.model_matrix = m.mat4Translate(transform.position) * m.mat4Scale(transform.scale)

    manager.transforms[id] = transform
}
