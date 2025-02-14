package orion

import "core:fmt"
import m "core:math/linalg/glsl"
import gl "vendor:OpenGL"

//Create a new entity with a mesh and a transform component 
initStaticMesh :: proc(scene: ^Scene, mesh: Shape, material: Material) -> entity_id{
    id := createEntity(scene)

    createMesh(scene, id, mesh, material)
    createTransform(scene.components, id, m.vec3{0, 0, 0}, m.vec3{0, 0, 0}, m.vec3{1, 1, 1})

    return id
}

//Create a new mesh component on an entity
createMesh :: proc(scene: ^Scene, id: entity_id, mesh: Shape, material: Material){
    scene.components.meshes[id] = StaticMesh{
        mesh = mesh,
        material = material,
    }

    initMeshBuffers(&scene.components.meshes[id])
}

initMeshBuffers :: proc(mesh: ^StaticMesh){
    mesh_object := mesh

    //VAO/VBO/EBO setup
    vao, vbo, ebo: u32
    gl.GenVertexArrays(1, &vao)
    gl.GenBuffers(1, &vbo)
    gl.GenBuffers(1, &ebo)

    mesh_object.vao = vao
    mesh_object.buffer_vertices = vbo
    mesh_object.buffer_indices = ebo


    gl.BindVertexArray(vao)

    // Vertex Buffer (like WebGL ARRAY_BUFFER)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(mesh_object.mesh.vertices) * size_of(f32), raw_data(mesh_object.mesh.vertices), gl.STATIC_DRAW)

    // Element Buffer (like WebGL ELEMENT_ARRAY_BUFFER)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(mesh_object.mesh.indices) * size_of(u16), raw_data(mesh_object.mesh.indices), gl.STATIC_DRAW)

    // Position attribute (similar to vertexAttribPointer)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)
}

meshDestroy :: proc(manager: ^ComponentManager, id: entity_id){
    mesh := &manager.meshes[id]
    gl.DeleteVertexArrays(1, &mesh.vao)
    gl.DeleteBuffers(1, &mesh.buffer_vertices)
    gl.DeleteBuffers(1, &mesh.buffer_indices)
    delete_key(&manager.meshes, id)
}

setModelMatrix :: proc(mesh: ^StaticMesh, x,y,z,scale: f32){
    identity := m.identity(m.mat4)
    translate := m.mat4Translate(m.vec3{x,y,z})
    scale := m.mat4Scale(m.vec3{scale,scale,scale})
    mesh.model_matrix = identity * translate * scale
}