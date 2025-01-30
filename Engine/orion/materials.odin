package orion

import "core:fmt"
import "core:os"
import m "core:math/linalg/glsl"
import gl "vendor:OpenGL"

Material :: struct {
    shader : ^Shader,
    color: m.vec4
}

Shader :: struct {
    program : u32,
    success : bool,
    vertex_position : u32,
    indices : u32,
    model_matrix : i32,
    view_matrix : i32,
    projection_matrix : i32,
    color : i32
}

//Initialize shader. Loads the vertex and fragment shaders from the shaders directory by name "name.glsl"
initShader :: proc(vertex_path: string, fragement_path: string) -> Shader {
    shader := Shader{}
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

    return shader
}