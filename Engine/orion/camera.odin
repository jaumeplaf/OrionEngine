package orion

import "core:fmt"
import m "core:math/linalg/glsl"
import gl "vendor:OpenGL"

Camera :: struct {
    fov: f32,
    position: m.vec3,
    target: m.vec3,
    forward_vec: m.vec3,
    up_vec: m.vec3,
    right_vec: m.vec3,
    yaw: f32,
    pitch: f32,
    max_pitch : f32,
    view_matrix: m.mat4,
    projection_matrix: m.mat4
}


initCamera :: proc(components: ^ComponentManager, entities: ^EntityManager, fov: f32, position: m.vec3, target: m.vec3) -> Camera {
    id := entityCreate(entities)
    camera := Camera{}
    //TODO: replace position, yaw, pitch with Transform component
    camera.position = position
    camera.target = target
    camera.forward_vec = m.normalize(target - position) 
    camera.up_vec = GAME.UP
    camera.right_vec = m.normalize(m.cross(camera.forward_vec, camera.up_vec))
    camera.yaw = -90.0
    camera.pitch = 0.0
    camera.max_pitch = m.PI / 2.0 - 0.01
    setViewMatrix(&camera)
    setProjectionMatrix(&camera, fov, GAME.RATIO)

    player01 := initPlayer(components, entities, &camera)

    components.cameras[id] = camera
    components.players[id] = player01

    return camera
}



rotateView :: proc(camera: ^Camera, deltaYaw: f32, deltaPitch: f32) {
    camera.yaw += deltaYaw
    camera.pitch += deltaPitch
    camera.pitch = m.max(-camera.max_pitch, m.min(camera.max_pitch, camera.pitch))
    camera.forward_vec = m.normalize(m.vec3{
        m.cos(camera.pitch) * m.sin(camera.yaw), 
        m.sin(camera.pitch), 
        m.cos(camera.pitch) * m.cos(camera.yaw)
    })
    camera.target = camera.position + camera.forward_vec
    setViewMatrix(camera)
    setProjectionMatrix(camera, 70.0, 800.0 / 600.0)
}

setViewMatrix :: proc(camera: ^Camera){
    camera.view_matrix = m.mat4LookAt(camera.position, camera.target, camera.up_vec)
}

setProjectionMatrix :: proc(camera: ^Camera, fov: f32, aspect_ratio: f32){
    camera.projection_matrix = m.mat4Perspective(m.radians_f32(fov), aspect_ratio, 0.1, 100.0) 
}
