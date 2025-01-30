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

initStaticMesh :: proc(model: Shape, material: Material) -> StaticMesh{
    mesh_object := StaticMesh{}
    mesh_object.mesh = model
    mesh_object.material = material

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

    return mesh_object
}

destroyStaticMesh :: proc(mesh: ^StaticMesh){
    gl.DeleteVertexArrays(1, &mesh.vao)
    gl.DeleteBuffers(1, &mesh.buffer_vertices)
    gl.DeleteBuffers(1, &mesh.buffer_indices)
}