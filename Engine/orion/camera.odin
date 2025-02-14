package orion

import "core:fmt"
import m "core:math/linalg/glsl"

initCamera :: proc(scene: ^Scene, fov: f32, style: CamStyle = .fps, near: f32, far: f32) -> entity_id{
    id := createEntity(scene)
    cam := cameraCreate(scene, id, fov, style, near, far)
    
    setProjectionMatrix(&cam)
    setViewMatrix(&cam)
    
    return id
}

//Styles: .editor, .fps, .isometric
cameraCreate :: proc(scene: ^Scene, id: entity_id, inFov: f32, cam_style: CamStyle, near: f32, far: f32) -> Camera{
    cam := Camera{
        style = cam_style,
        fov = inFov,
        position = m.vec3{0, 0, 0},
        target = m.vec3{0, 0, -10},
        yaw = m.PI,
        pitch = 0,
        max_pitch = m.PI / 2 - 0.01,
        up_vec = m.vec3{0,1,0},
        base_speed = 1,
        current_speed = 0,
        sprint = false,
        movement = .idle,
        near_plane = near,
        far_plane = far,
    }

    scene.components.cameras[id] = cam

    return cam
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

getSprint :: proc(cam: ^Camera){
    if cam.sprint{
        cam.current_speed = cam.base_speed * cam.sprint_mult
    }
    else{
        cam.current_speed = cam.base_speed
    }
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

setProjectionMatrix :: proc(cam: ^Camera){
    cam.projection_matrix = m.mat4Perspective(cam.fov, GAME.RATIO, cam.near_plane, cam.far_plane)
}

//Update view matrix using CamMovement
updateCameraPosition :: proc(cam: ^Camera){
    getDirectionVectors(cam)
    getSprint(cam)
    
    if cam.movement == .idle{
        //Camera is idle
    }
    if cam.movement == .forward && cam.movement != .back{
        cam.position[0] += cam.forward_vec[0] * cam.current_speed
        cam.position[2] += cam.forward_vec[2] * cam.current_speed
        cam.target[0] += cam.forward_vec[0] * cam.current_speed
        cam.target[2] += cam.forward_vec[2] * cam.current_speed
    }
    if cam.movement == .back{
        cam.position[0] -= cam.forward_vec[0] * cam.current_speed
        cam.position[2] -= cam.forward_vec[2] * cam.current_speed
        cam.target[0] -= cam.forward_vec[0] * cam.current_speed
        cam.target[2] -= cam.forward_vec[2] * cam.current_speed
    }
    if cam.movement == .left{
        cam.position[0] -= cam.right_vec[0] * cam.current_speed
        cam.position[2] -= cam.right_vec[2] * cam.current_speed
        cam.target[0] -= cam.right_vec[0] * cam.current_speed
        cam.target[2] -= cam.right_vec[2] * cam.current_speed
    }
    if cam.movement == .right && cam.movement != .left{
        cam.position[0] += cam.right_vec[0] * cam.current_speed
        cam.position[2] += cam.right_vec[2] * cam.current_speed
        cam.target[0] += cam.right_vec[0] * cam.current_speed
        cam.target[2] += cam.right_vec[2] * cam.current_speed
    }
    if cam.movement == .up && cam.movement != .down{ //can add up/down bounds
        cam.position[1] += cam.up_vec[1] * cam.current_speed
        cam.target[1] += cam.up_vec[1] * cam.current_speed
    }
    if cam.movement == .down{
        cam.position[1] -= cam.up_vec[1] * cam.current_speed
        cam.target[1] -= cam.up_vec[1] * cam.current_speed
    }

    setViewMatrix(cam)
}