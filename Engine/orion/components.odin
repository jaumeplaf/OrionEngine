package orion

import "core:fmt"
import m "core:math/linalg/glsl"

ComponentManager :: struct {
    transforms : map[entity_id]Transform,
    meshes : map[entity_id]StaticMesh,
    cameras : map[entity_id]Camera,
    players : map[entity_id]Player,
}

initComponentManager :: proc() -> ^ComponentManager {
    manager := new(ComponentManager)
    manager.transforms = make(map[entity_id]Transform)
    manager.meshes = make(map[entity_id]StaticMesh)
    manager.cameras = make(map[entity_id]Camera)
    manager.players = make(map[entity_id]Player)

    return manager
}

destroyComponents :: proc(components: ^ComponentManager, id: entity_id) {
    fmt.println("Destroying components for entity:", id)
    // Check and destroy StaticMesh
    if mesh, ok := components.meshes[id]; ok {
        fmt.println("Destroying StaticMesh for entity:", id)
        meshDestroy(components, id)
    } else {
        fmt.println("No StaticMesh found for entity:", id)
    }
    
    // Check and destroy Transform
    if _, ok := components.transforms[id]; ok {
        fmt.println("Destroying Transform for entity:", id)
        transformDestroy(components, id)
    } else {
        fmt.println("No Transform found for entity:", id)
    }
    
    // Check and destroy Camera
    if _, ok := components.cameras[id]; ok {
        fmt.println("Destroying Camera for entity:", id)
        //destroy camera proc
        delete_key(&components.cameras, id)
    } else {
        fmt.println("No Camera found for entity:", id)
    }
    
    // Check and destroy Player
    if _, ok := components.players[id]; ok {
        fmt.println("Destroying Player for entity:", id)
        //destroy player proc
        delete_key(&components.players, id)
    } else {
        fmt.println("No Player found for entity:", id)
    }
    fmt.println("Components destroyed for entity:", id)
}

//Add component to handle world position, rotation and scale
Transform :: struct {
    position : m.vec3,
    rotation : m.vec3, //Euler vs quat?
    scale : m.vec3,
}

//Add component to act as a rendering camera
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
//Add component to handle static mesh rendering
StaticMesh :: struct {
    mesh : Shape,
    material : Material,
    vao: u32,
    buffer_vertices : u32,
    buffer_indices : u32,
    buffer_normals : u32,
    buffer_colors : u32,
    buffer_texcoords : u32
}

//Add component to handle player data
Player :: struct {
	camera:     ^Camera,
	move_speed: f32,
	state:      PlayerState,
}