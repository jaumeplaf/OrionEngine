package orion

import "core:fmt"
import m "core:math/linalg/glsl"

initCamera :: proc(scene: ^Scene, fov: f32, style: CamStyle = .fps) -> entity_id{
    id := entityCreate(scene)
    cameraCreate(scene, id, fov, style)
    
    return id
}

//Styles: .editor, .fps, .isometric
cameraCreate :: proc(scene: ^Scene, id: entity_id, inFov: f32, cam_style: CamStyle){
    scene.components.cameras[id] = Camera{
        style = cam_style,
        fov = inFov,
        position = m.vec3{0, 0, 0},
        target = m.vec3{0, 0, -10},
        yaw = m.PI,
        pitch = 0,
        max_pitch = m.PI / 2 - 0.01,
        up_vec = m.vec3{0,1,0}
    }
}

rotateViewFPS :: proc(cam: ^Camera, deltaYaw: f32, deltaPitch: f32){
    cam.yaw -= deltaYaw
    cam.pitch -= deltaPitch
    cam.pitch = m.max_f32(-cam.max_pitch, m.min_f32(cam.max_pitch, cam.pitch))

    new_forward := m.vec3{
        m.cos_f32(cam.pitch) * m.sin_f32(cam.yaw),
        m.sin_f32(cam.pitch),
        m.cos_f32(cam.pitch) * m.cos_f32(cam.yaw)
    }
    
    cam.target = cam.position + new_forward
    setViewMatrix(cam)
}

getDirectionVectors :: proc(cam: ^Camera){
    forw := cam.target - cam.position
    cam.forward_vec = m.normalize_vec3(forw)

    right := m.cross_vec3(cam.forward_vec, cam.up_vec)
    cam.right_vec = m.normalize_vec3(right)

    cam.up_vec = m.normalize_vec3(cam.up_vec)
}

setViewMatrix :: proc(cam: ^Camera){
    cam.view_matrix = m.mat4LookAt(cam.position, cam.target, cam.up_vec)
}