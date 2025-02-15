package orion

import "core:fmt"
import m "core:math/linalg/glsl"

ComponentManager :: struct {
    transforms : map[entity_id]Transform,
    meshes : map[entity_id]StaticMesh,
    cameras : map[entity_id]Camera,
}

initComponentManager :: proc() -> ^ComponentManager {
    manager := new(ComponentManager)
    manager.transforms = make(map[entity_id]Transform)
    manager.meshes = make(map[entity_id]StaticMesh)
    manager.cameras = make(map[entity_id]Camera)

    return manager
}

destroyComponent :: proc(components: ^ComponentManager, id: entity_id) {
    // Check and destroy StaticMesh
    if mesh, ok := components.meshes[id]; ok {
        meshDestroy(components, id)
    } else {
        if GAME.DEBUG{
            fmt.println("No StaticMesh found for entity:", id)
        }
    }
    
    // Check and destroy Transform
    if _, ok := components.transforms[id]; ok {
        transformDestroy(components, id)
    } else {
        if GAME.DEBUG{
            fmt.println("No Transform found for entity:", id)
        }
    }
    
    // Check and destroy Camera
    if _, ok := components.cameras[id]; ok {
        //destroy camera proc
        delete_key(&components.cameras, id)
    } else {
        if GAME.DEBUG{
            fmt.println("No Camera found for entity:", id)
        }
    }
}

//Add component to handle world position, rotation and scale
Transform :: struct {
    position : m.vec3,
    rotation_axis : m.vec3,
    rotation_rads: f32,
    scale : m.vec3,
}

//Add component to act as a rendering camera
Camera :: struct {
    style: CamStyle,
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
    projection_matrix: m.mat4,
    base_speed: f32,
    current_speed: f32,
    sprint: bool,
    sprint_mult: f32,
    movement: CamMovement,
    near_plane: f32,
    far_plane: f32,
}

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

//Add component to handle static mesh rendering
StaticMesh :: struct {
    mesh : Shape,
    material : Material,
    model_matrix : m.mat4,
    vao: u32,
    buffer_vertices : u32,
    buffer_indices : u32,
    buffer_normals : u32,
    buffer_colors : u32,
    buffer_texcoords : u32
}