package base

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"

//Initialize shader. Loads the vertex and fragment shaders from the shaders directory by name "name.glsl"
initShader :: proc(vertex_path: string, fragement_path: string) -> u32 {
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
        return 0
    }
    if !os.exists(frag_path) {
        fmt.eprintln("Fragment shader not found at:", frag_path)
        return 0
    }
    
    program, ok := gl.load_shaders_file(vert_path, frag_path)
    if !ok {
        fmt.eprintln("Failed to load shaders at path:", vert_path, frag_path)
        return 0
    }
    fmt.println(vert_path, frag_path)
    return program
}