package orion

import "core:fmt"
import "vendor:glfw"
import gl "vendor:OpenGL"

initGL :: proc(width: i32, height: i32) {
    initGameState()

    // Initialize GLFW (similar to WebGL canvas context creation)

    if GAME.DEBUG {
        fmt.println("Initializing GLFW")
    }

    if glfw.Init() != true {
        fmt.eprintln("Failed to initialize GLFW")
        return
    }

    // Window hints (similar to WebGL context attributes)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GAME.GL_VERSION[0])
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GAME.GL_VERSION[1])
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
    glfw.SetScrollCallback(GAME.WINDOW, scrollCallback)
	glfw.SetCursorPosCallback(GAME.WINDOW, cursorPositionCallback)
	glfw.SetFramebufferSizeCallback(GAME.WINDOW, framebufferSizeCallback)

    //glfw.SetInputMode(GAME.WINDOW, glfw.CURSOR, glfw.CURSOR_CAPTURED)

    // Load OpenGL functions (automatic in WebGL, explicit here)
    gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

    GAME.RATIO = getAspectRatio_i32(width, height)
    gl.Viewport(0, 0, width, height)

    initRendering()

}

//Global rendering parameters, runs once at the start
initRendering :: proc(){
    gl.Enable(gl.DEPTH_TEST)
    gl.ClearColor(0.5, 0.5, 0.5, 1.0)  // 50% gray background
}

//Draw scene, runs every frame
drawSystem :: proc(scene: ^Scene) {
    components := scene.components
    entities := scene.entities
    meshes := components.meshes
    
    // Render
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
    

    current_shader: u32 = 0
    cam, has_cam := components.cameras[GAME.ACTIVE_CAMERA]

    for id, is_alive in entities.alive {
        if !is_alive {
            continue
        }

        mesh, has_mesh := components.meshes[id]
        transform, has_transform := components.transforms[id]
        
        if has_mesh && has_transform {
            if mesh.material.shader.program != current_shader {
                current_shader = mesh.material.shader.program
                gl.UseProgram(current_shader)

                if has_cam {
                    gl.UniformMatrix4fv(mesh.material.shader.view_matrix_index, 1, false, &cam.view_matrix[0][0])
                    gl.UniformMatrix4fv(mesh.material.shader.projection_matrix_index, 1, false, &cam.projection_matrix[0][0])
                }
            }

            // Always set model matrix before draw
            gl.UniformMatrix4fv(mesh.material.shader.model_matrix_index, 1, false, &mesh.model_matrix[0][0])

            gl.BindVertexArray(mesh.vao)
            gl.DrawElements(gl.TRIANGLES, i32(len(mesh.mesh.indices)), gl.UNSIGNED_SHORT, nil)
        }
    }

    glfw.SwapBuffers(GAME.WINDOW)
    glfw.PollEvents()

}