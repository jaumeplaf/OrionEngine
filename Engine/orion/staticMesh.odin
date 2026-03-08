package orion

import "core:fmt"
import m "core:math/linalg/glsl"

//Create a new entity with a mesh and a transform component 
initStaticMesh :: proc(mesh: Shape, material: ^Material) -> entity_id{
    scene := GAME.ACTIVE_SCENE
    id := createEntity(scene)
    if GAME.DEBUG {
        fmt.println("Creating entity with id:", id)
    }
    if GAME.DEBUG {
        fmt.println("Initializing mesh")
    }
    createMesh(id, mesh, material)
    if GAME.DEBUG {
        fmt.println("Initializing mesh's transform")
    }
    createTransform(id, m.vec3{0, 0, 0}, m.vec3{0, 1, 0}, 0, m.vec3{1, 1, 1})
    
    cam := scene.components.cameras[GAME.ACTIVE_CAMERA]

    if GAME.DEBUG {
        fmt.println("Active camera: ", cam)
    }

    return id
}

initLineMesh :: proc(mesh: Shape, material: ^Material) -> entity_id{
    scene := GAME.ACTIVE_SCENE
    id := createEntity(scene)
    if GAME.DEBUG {
        fmt.println("Creating line entity with id:", id)
    }

    createMesh(id, mesh, material, .Lines)
    createTransform(id, m.vec3{0, 0, 0}, m.vec3{0, 1, 0}, 0, m.vec3{1, 1, 1})

    return id
}

//Create a new mesh component on an entity
createMesh :: proc(id: entity_id, mesh: Shape, material: ^Material, draw_mode: RHI_Primitive = .Triangles){
    scene := GAME.ACTIVE_SCENE
    scene.components.meshes[id] = StaticMesh{
        mesh = mesh,
        material = material^,
        draw_mode = draw_mode,
    }

    initMeshBuffers(&scene.components.meshes[id])
}

initMeshBuffers :: proc(mesh: ^StaticMesh){
    mesh_object := mesh

    //VAO/VBO/EBO setup
    vao, vbo, ebo := rhiCreateMeshBuffers(mesh_object.mesh.vertices, mesh_object.mesh.indices)

    mesh_object.vao = vao
    mesh_object.buffer_vertices = vbo
    mesh_object.buffer_indices = ebo

    mesh_object.model_matrix = m.identity(m.mat4)

}

meshDestroy :: proc(id: entity_id){
    components := GAME.ACTIVE_SCENE.components
    mesh := &components.meshes[id]
    rhiDestroyMeshBuffers(&mesh.vao, &mesh.buffer_vertices, &mesh.buffer_indices)
    delete_key(&components.meshes, id)
}

calculateModelMatrix :: proc(mesh: ^StaticMesh, position: m.vec3, rotation_axis: m.vec3, rotation_degs: f32, scale: m.vec3){
    translate := m.mat4Translate(position)

    axis := rotation_axis
    null := m.vec3{0,0,0}
    rads := degsToRads(rotation_degs)
    //Check for invalid rotation axis
    if axis == null{
        fmt.println("Error, invalid rotation axis")
        axis = m.vec3{0,1,0}
        rads = 0
    }
    rotation := m.mat4Rotate(axis, rads)
    scale := m.mat4Scale(scale)
    mesh.model_matrix =  translate * rotation * scale
}

updateModelMatrix :: proc(id: entity_id){
    scene := GAME.ACTIVE_SCENE
    if transform, ok := scene.components.transforms[id]; ok {
        if mesh, ok  := scene.components.meshes[id]; ok {
            calculateModelMatrix(&scene.components.meshes[id], transform.position, transform.rotation_axis, transform.rotation, transform.scale)
            setModelMatrix(id)
        }
    }
}

