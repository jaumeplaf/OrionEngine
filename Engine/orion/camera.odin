package orion

import "core:fmt"
import m "core:math/linalg/glsl"

CamMovement :: enum{
    idle,
    forward,
    left,
    back,
    right,
    up,
    down,
}

CamStyle :: enum{
    editor,
    fps,
    isometric,    
}

initCamera :: proc(fov: f32, style: CamStyle = .fps, near: f32, far: f32){
    scene := GAME.ACTIVE_SCENE
    id := createEntity(scene)
    if GAME.DEBUG {
        fmt.println("Initializing camera with id:", id) 
    }
    cam := cameraCreate(id, fov, style, near, far)
    
    fmt.println("Camera initialized: ", cam)
    
    return
}

//Styles: .editor, .fps, .isometric
cameraCreate :: proc(id: entity_id, inFov: f32, cam_style: CamStyle, near: f32, far: f32) -> Camera{
    scene := GAME.ACTIVE_SCENE
    cam := Camera{
        style = cam_style,
        fov = inFov,
        position = m.vec3{0, 0, 10},
        target = m.vec3{0, 0, 0},
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
        view_matrix = m.mat4LookAt(m.vec3{0, 0, 0}, m.vec3{0, 0, -10}, m.vec3{0,1,0}),
        projection_matrix = m.mat4Perspective(inFov, GAME.RATIO, near, far),
    }
    scene.components.cameras[id] = cam
    GAME.ACTIVE_CAMERA = id

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
    if GAME.INPUT.SPRINT{
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

calculateViewMatrix :: proc(cam: ^Camera){
    cam.view_matrix = m.mat4LookAt(cam.position, cam.target, cam.up_vec)
}

calculateProjectionMatrix :: proc(cam: ^Camera){
    cam.projection_matrix = m.mat4Perspective(cam.fov, GAME.RATIO, cam.near_plane, cam.far_plane)
}

setViewMatrix :: proc(cam: ^Camera){
    calculateViewMatrix(cam)
    updateViewMatrix()
}

setProjectionMatrix :: proc(cam: ^Camera){
    calculateProjectionMatrix(cam)
    updateProjectionMatrix()
}

//Update view matrix using CamMovement
updateCameraPosition :: proc(cam: ^Camera){
    getDirectionVectors(cam)
    getSprint(cam)
    input := GAME.INPUT

    fmt.println("Updating camera position: ", input)
    
    if input.FORWARD && !input.BACKWARD {
        cam.position[0] += cam.forward_vec[0] * cam.current_speed
        cam.position[2] += cam.forward_vec[2] * cam.current_speed
        cam.target[0] += cam.forward_vec[0] * cam.current_speed
        cam.target[2] += cam.forward_vec[2] * cam.current_speed
        fmt.println("Moving forward")
    }
    if input.BACKWARD && !input.FORWARD {
        cam.position[0] -= cam.forward_vec[0] * cam.current_speed
        cam.position[2] -= cam.forward_vec[2] * cam.current_speed
        cam.target[0] -= cam.forward_vec[0] * cam.current_speed
        cam.target[2] -= cam.forward_vec[2] * cam.current_speed
        fmt.println("Moving backward")
    }
    if input.LEFT && !input.RIGHT {
        cam.position[0] -= cam.right_vec[0] * cam.current_speed
        cam.position[2] -= cam.right_vec[2] * cam.current_speed
        cam.target[0] -= cam.right_vec[0] * cam.current_speed
        cam.target[2] -= cam.right_vec[2] * cam.current_speed
        fmt.println("Moving left")
    }
    if input.RIGHT && !input.LEFT {
        cam.position[0] += cam.right_vec[0] * cam.current_speed
        cam.position[2] += cam.right_vec[2] * cam.current_speed
        cam.target[0] += cam.right_vec[0] * cam.current_speed
        cam.target[2] += cam.right_vec[2] * cam.current_speed
        fmt.println("Moving right")
    }
    if input.JUMP && !input.CROUCH { //can add up/down bounds
        cam.position[1] += cam.up_vec[1] * cam.current_speed
        cam.target[1] += cam.up_vec[1] * cam.current_speed
    }
    if input.CROUCH && !input.JUMP {
        cam.position[1] -= cam.up_vec[1] * cam.current_speed
        cam.target[1] -= cam.up_vec[1] * cam.current_speed
    }

    setViewMatrix(cam)
}
