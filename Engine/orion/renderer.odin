package orion

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"

initGL :: proc(width: i32, height: i32) {
    // Initialize GLFW (similar to WebGL canvas context creation)
    if glfw.Init() != true {
        fmt.eprintln("Failed to initialize GLFW")
        return
    }

    // Window hints (similar to WebGL context attributes)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    when ODIN_OS == .Darwin {  // Needed for macOS
        glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, 1)
    }

    // Create window (like creating a canvas element in WebGL)
    GAME.WINDOW = glfw.CreateWindow(width, height, "Orion", nil, nil)
    if GAME.WINDOW == nil {
        fmt.eprintln("Failed to create GLFW window")
        return
    }

    glfw.MakeContextCurrent(GAME.WINDOW)
    //Enable callbacks
	glfw.SetKeyCallback(GAME.WINDOW, keyCallback)
	glfw.SetMouseButtonCallback(GAME.WINDOW, mouseCallback)
	glfw.SetCursorPosCallback(GAME.WINDOW, cursorPositionCallback)
	glfw.SetFramebufferSizeCallback(GAME.WINDOW, framebufferSizeCallback)

    // Load OpenGL functions (automatic in WebGL, explicit here)
    gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
}

draw :: proc(scene: ^Scene) {
    components := scene.components
    entities := scene.entities
    meshes := components.meshes

    
    // Render
    gl.ClearColor(0.5, 0.5, 0.5, 1.0)  // 50% gray background
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
    gl.Enable(gl.DEPTH_TEST)

    current_shader: u32 = 0

    for id, is_alive in entities.alive {
        // Only process entities with both mesh and transform
        mesh, has_mesh := components.meshes[id]
        transform, has_transform := components.transforms[id]
        
        if has_mesh && has_transform {
            // Change shader only when needed
            if mesh.material.shader.program != current_shader {
                current_shader = mesh.material.shader.program
                gl.UseProgram(current_shader)
            }

            // Set transform uniforms here
            // TODO: Add uniform handling for model matrix

            gl.BindVertexArray(mesh.vao)
            gl.DrawElements(gl.TRIANGLES, i32(len(mesh.mesh.indices)), gl.UNSIGNED_SHORT, nil)
        }
    }

    glfw.SwapBuffers(GAME.WINDOW)
    glfw.PollEvents()

}

