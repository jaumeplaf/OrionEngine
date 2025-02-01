package orion

import "core:fmt"
import gl "vendor:OpenGL"

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

initMeshBuffers :: proc(manager: ^ComponentManager, id: entity_id){
    mesh_object := manager.static_meshes[id]
    //VAO/VBO/EBO setup
    vao, vbo, ebo: u32
    gl.GenVertexArrays(1, &vao)
    gl.GenBuffers(1, &vbo)
    gl.GenBuffers(1, &ebo)

    mesh_object.vao = vao
    mesh_object.buffer_vertices = vbo
    mesh_object.buffer_indices = ebo


    gl.BindVertexArray(vao)

    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(mesh_object.mesh.vertices) * size_of(f32), raw_data(mesh_object.mesh.vertices), gl.STATIC_DRAW)

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(mesh_object.mesh.indices) * size_of(u16), raw_data(mesh_object.mesh.indices), gl.STATIC_DRAW)

    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    manager.static_meshes[id] = mesh_object
}

//Initialize static mesh component
componentStaticMesh :: proc(manager : ^ComponentManager, id : entity_id, mesh : Shape, material : Material){
    static_mesh := StaticMesh{}
    static_mesh.mesh = mesh
    static_mesh.material = material
    manager.static_meshes[id] = static_mesh
    initMeshBuffers(manager, id)
}

initStaticMesh :: proc(components: ^ComponentManager, entities: ^EntityManager, 
    mesh: Shape, material: Material) -> StaticMesh{
    id := entityCreate(entities)
    componentTransform(components, id)
    componentStaticMesh(components, id, mesh, material)
    return components.static_meshes[id]
}

destroyStaticMesh :: proc(mesh: ^StaticMesh){
    gl.DeleteVertexArrays(1, &mesh.vao)
    gl.DeleteBuffers(1, &mesh.buffer_vertices)
    gl.DeleteBuffers(1, &mesh.buffer_indices)
}

//Change material of existing static mesh component
setStaticMeshMaterial :: proc(manager : ^ComponentManager, id : entity_id, material : Material){
    static_mesh := manager.static_meshes[id]
    static_mesh.material = material
    manager.static_meshes[id] = static_mesh
}