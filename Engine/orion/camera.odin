package orion

import "core:fmt"
import m "core:math/linalg/glsl"
import "vendor:glfw"

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

initCamera :: proc(fov: f32, style: CamStyle = .fps, near: f32, far: f32, init_pos: m.vec3 = m.vec3{0,1.7,10}) -> entity_id {
    scene := GAME.ACTIVE_SCENE
    id := createEntity(scene)
    if GAME.DEBUG {
        fmt.println("Initializing camera with id:", id) 
    }
    cam := cameraCreate(id, fov, style, near, far, init_pos)
    if GAME.DEBUG {
        fmt.println("Camera initialized: ", cam)
    }

    return id
}

//Styles: .editor, .fps, .isometric
cameraCreate :: proc(id: entity_id, inFov: f32, cam_style: CamStyle, near: f32, far: f32, init_pos: m.vec3) -> Camera{
    scene := GAME.ACTIVE_SCENE
    cam := Camera{
        style = cam_style,
        fov = inFov,
        position = init_pos,
        target = m.vec3{0, 0, 0},
        yaw = 0,
        pitch = 0,
        max_pitch = m.PI / 2 - 0.01,
        up_vec = m.vec3{0,1,0},
        base_speed = MOVE_SPEED,
        current_speed = 0,
        sprint = false,
        sprint_mult = SPRINT_SPEED,
        speed_mult = 1,
        movement = .idle,
        near_plane = near,
        far_plane = far,
        stand_y = init_pos[1],
        crouch_y = init_pos[1] * 0.5,
        vertical_velocity = 0,
        is_jumping = false,
    }

    initial_forward := m.normalize_vec3(cam.target - cam.position)
    cam.pitch = m.asin_f32(initial_forward[1])
    cam.pitch = m.max_f32(-cam.max_pitch, m.min_f32(cam.max_pitch, cam.pitch))
    cam.yaw = m.atan2_f32(initial_forward[0], initial_forward[2])

    cam.view_matrix = m.mat4LookAt(cam.position, cam.target, cam.up_vec)
    cam.projection_matrix = m.mat4Perspective(degsToRads(inFov), GAME.RATIO, near, far)

    scene.components.cameras[id] = cam
    GAME.ACTIVE_CAMERA = id

    return cam
}

syncAnglesFromTarget :: proc(cam: ^Camera) {
    forward := m.normalize_vec3(cam.target - cam.position)
    cam.pitch = m.asin_f32(forward[1])
    cam.pitch = m.max_f32(-cam.max_pitch, m.min_f32(cam.max_pitch, cam.pitch))
    cam.yaw = m.atan2_f32(forward[0], forward[2])
}

applyCursorModeForCamera :: proc(style: CamStyle) {
    if style == .fps {
        glfw.SetInputMode(GAME.WINDOW, glfw.CURSOR, glfw.CURSOR_DISABLED)
        GAME.INPUT.MOUSE_LOOK_ACTIVE = true
        GAME.INPUT.MOUSE_INITIALIZED = false
        GAME.INPUT.MOUSE_WARMUP_FRAMES = 2
        GAME.INPUT.MOUSE_DELTA = [2]f64{0, 0}
        GAME.INPUT.MOUSE_SKIP_NEXT_DELTA = true
    } else {
        if GAME.INPUT.RIGHT_CLICK {
            glfw.SetInputMode(GAME.WINDOW, glfw.CURSOR, glfw.CURSOR_DISABLED)
            GAME.INPUT.MOUSE_LOOK_ACTIVE = true
        } else {
            glfw.SetInputMode(GAME.WINDOW, glfw.CURSOR, glfw.CURSOR_NORMAL)
            GAME.INPUT.MOUSE_LOOK_ACTIVE = false
        }
        GAME.INPUT.MOUSE_INITIALIZED = false
        GAME.INPUT.MOUSE_WARMUP_FRAMES = 2
        GAME.INPUT.MOUSE_DELTA = [2]f64{0, 0}
        GAME.INPUT.MOUSE_SKIP_NEXT_DELTA = true
    }
}

swapActiveCamera :: proc() {
    scene := GAME.ACTIVE_SCENE
    if scene == nil {
        return
    }

    current_id := GAME.ACTIVE_CAMERA
    next_id := GAME.EDITOR_CAMERA
    if current_id == GAME.EDITOR_CAMERA {
        next_id = GAME.FPS_CAMERA
    }

    current_cam := scene.components.cameras[current_id]
    next_cam := scene.components.cameras[next_id]

    next_cam.position = current_cam.position
    if next_cam.style == .fps {
        next_cam.position[1] = next_cam.stand_y
    }

    look_dir := m.normalize_vec3(current_cam.target - current_cam.position)
    next_cam.target = next_cam.position + look_dir
    syncAnglesFromTarget(&next_cam)
    calculateViewMatrix(&next_cam)

    scene.components.cameras[next_id] = next_cam
    GAME.ACTIVE_CAMERA = next_id
    applyCursorModeForCamera(next_cam.style)
    updateViewMatrix()

    if next_cam.style == .fps {
        fmt.println("Swapping to FPS camera")
    } else {
        fmt.println("Swapping to EDITOR camera")
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
    calculateViewMatrix(cam)
}

updateCameraLookFPS :: proc(cam: ^Camera) {
    input := GAME.INPUT

    if !input.MOUSE_LOOK_ACTIVE {
        return
    }

    delta_x := input.MOUSE_DELTA[0]
    delta_y := input.MOUSE_DELTA[1]
    input.MOUSE_DELTA = [2]f64{0, 0}

    if delta_x == 0 && delta_y == 0 {
        return
    }

    mouse_sensitivity: f32 = 0.0025 * SENSITIVITY
    rotateViewFPS(cam, f32(delta_x) * mouse_sensitivity, f32(delta_y) * mouse_sensitivity)
}

updateEditorSpeedFromScroll :: proc(cam: ^Camera) {
    input := GAME.INPUT
    if input.SCROLL_DELTA == 0 {
        return
    }

    cam.speed_mult += f32(input.SCROLL_DELTA) * EDITOR_SCROLL_STEP
    cam.speed_mult = m.max_f32(EDITOR_SPEED_MIN, m.min_f32(EDITOR_SPEED_MAX, cam.speed_mult))
    input.SCROLL_DELTA = 0
    input.SCROLL_UP = false
    input.SCROLL_DOWN = false
}

getSprint :: proc(cam: ^Camera){
    if cam.style == .editor {
        cam.current_speed = cam.base_speed * cam.speed_mult
        return
    }

    if GAME.INPUT.CROUCH {
        cam.current_speed = cam.base_speed * CROUCH_SPEED_MULT
    } else if GAME.INPUT.SPRINT {
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
    projection := m.mat4Perspective(degsToRads(cam.fov), GAME.RATIO, cam.near_plane, cam.far_plane)
    cam.projection_matrix = projection
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
    if cam.style == .editor {
        updateEditorSpeedFromScroll(cam)
    }
    getSprint(cam)
    input := GAME.INPUT

    if GAME.DEBUG {
        fmt.println("Updating camera position: ", input)
    }
    
    if input.FORWARD && !input.BACKWARD {
        cam.position[0] += cam.forward_vec[0] * cam.current_speed
        cam.position[2] += cam.forward_vec[2] * cam.current_speed
        cam.target[0] += cam.forward_vec[0] * cam.current_speed
        cam.target[2] += cam.forward_vec[2] * cam.current_speed
        if GAME.DEBUG {
            fmt.println("Moving forward")
        }
    }
    if input.BACKWARD && !input.FORWARD {
        cam.position[0] -= cam.forward_vec[0] * cam.current_speed
        cam.position[2] -= cam.forward_vec[2] * cam.current_speed
        cam.target[0] -= cam.forward_vec[0] * cam.current_speed
        cam.target[2] -= cam.forward_vec[2] * cam.current_speed
        if GAME.DEBUG {
            fmt.println("Moving backward")
        }
    }
    if input.LEFT && !input.RIGHT {
        cam.position[0] -= cam.right_vec[0] * cam.current_speed
        cam.position[2] -= cam.right_vec[2] * cam.current_speed
        cam.target[0] -= cam.right_vec[0] * cam.current_speed
        cam.target[2] -= cam.right_vec[2] * cam.current_speed
        if GAME.DEBUG {
            fmt.println("Moving left")
        }
    }
    if input.RIGHT && !input.LEFT {
        cam.position[0] += cam.right_vec[0] * cam.current_speed
        cam.position[2] += cam.right_vec[2] * cam.current_speed
        cam.target[0] += cam.right_vec[0] * cam.current_speed
        cam.target[2] += cam.right_vec[2] * cam.current_speed
        if GAME.DEBUG {
            fmt.println("Moving right")
        }
    }
    if cam.style == .editor {
        if input.JUMP && !input.CROUCH {
            cam.position[1] += cam.up_vec[1] * cam.current_speed
            cam.target[1] += cam.up_vec[1] * cam.current_speed
        }
        if input.CROUCH && !input.JUMP {
            cam.position[1] -= cam.up_vec[1] * cam.current_speed
            cam.target[1] -= cam.up_vec[1] * cam.current_speed
        }
    } else {
        ground_y := cam.stand_y
        if input.CROUCH {
            ground_y = cam.crouch_y
        }

        if !cam.is_jumping && input.JUMP {
            cam.is_jumping = true
            cam.vertical_velocity = JUMP_VELOCITY
        }

        if cam.is_jumping {
            cam.vertical_velocity -= GRAVITY_ACCEL
            delta_y := cam.vertical_velocity
            cam.position[1] += delta_y
            cam.target[1] += delta_y
        }

        if !cam.is_jumping {
            delta_to_ground := ground_y - cam.position[1]
            cam.position[1] = ground_y
            cam.target[1] += delta_to_ground
        }

        if cam.position[1] <= ground_y {
            delta_to_ground := ground_y - cam.position[1]
            cam.position[1] = ground_y
            cam.target[1] += delta_to_ground
            cam.vertical_velocity = 0
            cam.is_jumping = false
        }
    }

    calculateViewMatrix(cam)
}
