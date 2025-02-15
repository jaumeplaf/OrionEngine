package orion

import "core:fmt"
import "core:os"
import m "core:math/linalg/glsl"
import gl "vendor:OpenGL"


Material :: struct {
    shader : ^Shader,
    base_color : m.vec4,
    //other uniforms
}

Shader :: struct {
    program : u32,
    success : bool,
    vertex_position : u32,
    indices : u32,
    model_matrix_index : i32,
    view_matrix_index : i32,
    projection_matrix_index : i32,
    color : i32
}

material :: proc(shader: ^Shader, color: m.vec4) -> Material {
    return Material{
        shader = shader,
        base_color = color,
    }
}

//Initialize shader. Loads the vertex and fragment shaders from the shaders directory by name "name.glsl"
createShader :: proc(vertex_path: string, fragement_path: string) -> ^Shader {
    shader := new(Shader)
    shader_dir := os.get_current_directory() // Get executable's directory

    when ODIN_OS == .Darwin || ODIN_OS == .Linux  { //macOS and Linux use forward slashes
        vert_path := fmt.tprintf("%s/shaders/%s", shader_dir, vertex_path)
        frag_path := fmt.tprintf("%s/shaders/%s", shader_dir, fragement_path)
    }
    else{ //Windows uses backslashes
        vert_path := fmt.tprintf("%s\\shaders\\%s", shader_dir, vertex_path)
        frag_path := fmt.tprintf("%s\\shaders\\%s", shader_dir, fragement_path)
    }
    if !os.exists(vert_path) {
        fmt.eprintln("Vertex shader not found at:", vert_path)
    }
    if !os.exists(frag_path) {
        fmt.eprintln("Fragment shader not found at:", frag_path)
    }
    
    shader.program, shader.success = gl.load_shaders_file(vert_path, frag_path)
    if !shader.success {
        fmt.eprintln("Failed to load shaders at path:", vert_path, frag_path)
    }

    initializeUniforms(shader)

    return shader
}

destroyShader :: proc(shader: ^Shader) {
    gl.DeleteProgram(shader.program)
    free(shader)
}
destroyMaterial :: proc(material: ^Material) {
    free(material)
}

initializeUniforms :: proc(shader: ^Shader){
    shader.model_matrix_index = gl.GetUniformLocation(shader.program, "model_matrix")
    //shader.view_matrix_index = gl.GetUniformLocation(shader.program, "view_matrix")
    //shader.projection_matrix_index = gl.GetUniformLocation(shader.program, "projection_matrix")
}

setModelMatrix :: proc(scene: ^Scene, id: entity_id){
    mesh := scene.components.meshes[id]
    //TODO: fix thiis, not working
    gl.UniformMatrix4fv(mesh.material.shader.model_matrix_index, 0, false, &mesh.model_matrix[0,0])
}

updateUniforms :: proc(program: u32){

}