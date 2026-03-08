package orion

import "core:fmt"
import "core:os"
import "base:runtime"
import m "core:math/linalg/glsl"


Material :: struct {
    shader : ^Shader,
    base_color : m.vec4,
    //other uniforms
}

Shader :: struct {
    pipeline_handle : u32,
    success : bool,
    model_uniform : i32,
    view_uniform : i32,
    projection_uniform : i32,
    color_uniform : i32,
}

ShaderManager :: struct {
    shaders : []^Shader,
    next_id : i32,
}

initShaderManager :: proc() -> ^ShaderManager {
    manager := new(ShaderManager)
    manager.shaders = make([]^Shader, MAX_SHADERS)
    manager.next_id = 0
    return manager
}

//Append shader to the shader manager
appendShader :: proc(shader: ^Shader){
    scene := GAME.ACTIVE_SCENE
    sm := scene.shaders
    sm.shaders[sm.next_id] = shader
    sm.next_id += 1
}

createMaterial :: proc(shader: ^Shader, color: m.vec4) -> ^Material {
    mat := new(Material)
    mat.shader = shader
    mat.base_color = color
    return mat
}

//Initialize shader. Loads the vertex and fragment shaders from the shaders directory by name "name.glsl"
createShader :: proc(vertex_path: string, fragement_path: string) -> ^Shader {
    shader := new(Shader)
    appendShader(shader)
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
    
    shader.pipeline_handle, shader.success = rhiCreateShaderProgram(vert_path, frag_path)
    if !shader.success {
        fmt.eprintln("Failed to load shaders at path:", vert_path, frag_path)
    }

    initializeUniforms(shader)

    return shader
}

destroyShader :: proc(shader: ^Shader) {
    rhiDestroyShaderProgram(shader.pipeline_handle)
    free(shader)
}
destroyMaterial :: proc(material: ^Material) {
    free(material)
}

initializeUniforms :: proc(shader: ^Shader){
    if !shader.success || shader.pipeline_handle == 0 {
        return
    }

    if GAME.DEBUG {
        fmt.println("Initializing model matrix index")
    }
    shader.model_uniform = rhiGetUniformLocation(shader.pipeline_handle, "model_matrix")
    if GAME.DEBUG {
        fmt.println("Initializing view matrix index")
    } 
    shader.view_uniform = rhiGetUniformLocation(shader.pipeline_handle, "view_matrix")
    if GAME.DEBUG {
        fmt.println("Initializing projection matrix index")
    }
    shader.projection_uniform = rhiGetUniformLocation(shader.pipeline_handle, "projection_matrix")
    shader.color_uniform = rhiGetUniformLocation(shader.pipeline_handle, "color")

    scene := GAME.ACTIVE_SCENE
    if scene == nil {
        return
    }
    if cam, ok := scene.components.cameras[GAME.ACTIVE_CAMERA]; ok {
        rhiUseProgram(shader.pipeline_handle)
        if shader.view_uniform >= 0 {
            rhiSetUniformMat4(shader.view_uniform, &cam.view_matrix[0][0])
        }
        if shader.projection_uniform >= 0 {
            rhiSetUniformMat4(shader.projection_uniform, &cam.projection_matrix[0][0])
        }
    }
}

setModelMatrix :: proc(id: entity_id){
    scene := GAME.ACTIVE_SCENE
    mesh := scene.components.meshes[id]
    rhiUseProgram(mesh.material.shader.pipeline_handle)
    rhiSetUniformMat4(mesh.material.shader.model_uniform, &mesh.model_matrix[0][0])
}

updateViewMatrix :: proc(){
    scene := GAME.ACTIVE_SCENE
    shaders := scene.shaders.shaders
    
    if GAME.DEBUG {
                fmt.println("Shaders: ", shaders)
            }
    cam := scene.components.cameras[GAME.ACTIVE_CAMERA]
    for shader in shaders {
        if shader != nil && shader.success && shader.pipeline_handle != 0 {
            if GAME.DEBUG {
                fmt.println("Initializing shader: ", shader.pipeline_handle)
            }
            if shader.view_uniform >= 0 {
                rhiUseProgram(shader.pipeline_handle)
                if GAME.DEBUG {
                    fmt.println("Setting view matrix: ", cam.view_matrix)
                }
                rhiSetUniformMat4(shader.view_uniform, &cam.view_matrix[0][0])
            }
        }
    }
}

updateProjectionMatrix :: proc(){
    scene := GAME.ACTIVE_SCENE
    shaders := scene.shaders.shaders
    if GAME.DEBUG {
        fmt.println("Shader array: ", shaders)
    }
    cam := scene.components.cameras[GAME.ACTIVE_CAMERA]
    if GAME.DEBUG {
        fmt.println("--> Active camera: ", GAME.ACTIVE_CAMERA)
    }
    for shader in shaders {
        if shader != nil && shader.success && shader.pipeline_handle != 0 {
            if GAME.DEBUG {
                fmt.println("Initializing shader: ", shader.pipeline_handle)
            }
            if shader.projection_uniform >= 0 {
                rhiUseProgram(shader.pipeline_handle)
                if GAME.DEBUG {
                    fmt.println("Setting projection matrix: ", cam.projection_matrix)
                }
                rhiSetUniformMat4(shader.projection_uniform, &cam.projection_matrix[0][0])
            }
        }

    }
    if GAME.DEBUG {
        fmt.println("Projection matrix set")
    }
}