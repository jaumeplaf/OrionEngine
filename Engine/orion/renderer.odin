package orion

import "core:fmt"

initWindow :: proc(width: i32, height: i32) {
    initGameState()

    // Initialize the active window/render backend.

    if GAME.DEBUG {
        fmt.println("Initializing render window")
    }

    if !rhiInitWindow(width, height, "Orion", GAME.GL_VERSION[0], GAME.GL_VERSION[1]) {
        fmt.eprintln("Failed to initialize rendering window/context")
        return
    }

    fb_width, fb_height := rhiGetFramebufferSize()
    if fb_width <= 0 || fb_height <= 0 {
        fb_width = width
        fb_height = height
    }

    // On macOS Retina displays the framebuffer can be larger than the logical window size.
    // Initialize the viewport from framebuffer size so the first frame is rendered correctly.
    GAME.RATIO = getAspectRatio_i32(fb_width, fb_height)
    rhiSetViewport(0, 0, fb_width, fb_height)

    initRendering()
    initUiRenderer(GAME.UI)

}

//Global rendering parameters, runs once at the start
initRendering :: proc(){
    rhiEnableDepthTest(true)
    rhiSetClearColor(0.5, 0.5, 0.5, 1.0)  // 50% gray background
}

destroyRendering :: proc() {
    rhiShutdownWindow()
}

//Draw scene, runs every frame
drawSystem :: proc(scene: ^Scene) {
    components := scene.components
    entities := scene.entities
    meshes := components.meshes
    
    // Render
    rhiBeginFrame()
    

    current_shader: u32 = 0
    cam, has_cam := components.cameras[GAME.ACTIVE_CAMERA]

    for id, is_alive in entities.alive {
        if !is_alive {
            continue
        }

        mesh, has_mesh := components.meshes[id]
        transform, has_transform := components.transforms[id]
        
        if has_mesh && has_transform {
            if !mesh.material.shader.success || mesh.material.shader.pipeline_handle == 0 {
                continue
            }

            if mesh.material.shader.pipeline_handle != current_shader {
                current_shader = mesh.material.shader.pipeline_handle
                rhiUseProgram(current_shader)

                if has_cam {
                    if mesh.material.shader.view_uniform >= 0 {
                        rhiSetUniformMat4(mesh.material.shader.view_uniform, &cam.view_matrix[0][0])
                    }
                    if mesh.material.shader.projection_uniform >= 0 {
                        rhiSetUniformMat4(mesh.material.shader.projection_uniform, &cam.projection_matrix[0][0])
                    }
                }
            }

            // Always set model matrix before draw
            if mesh.material.shader.model_uniform >= 0 {
                rhiSetUniformMat4(mesh.material.shader.model_uniform, &mesh.model_matrix[0][0])
            }
            if mesh.material.shader.color_uniform >= 0 {
                rhiSetUniformVec4(mesh.material.shader.color_uniform, &mesh.material.base_color[0])
            }

            rhiBindVertexArray(mesh.vao)
            if mesh.draw_mode == .Lines {
                rhiSetLineWidth(AXIS_WIDTH)
            } 
            else {
                rhiSetLineWidth(1.0)
            }
            rhiDrawIndexed(mesh.draw_mode, i32(len(mesh.mesh.indices)))
        }
    }

    updateUi(GAME.UI)
    rhiEnableDepthTest(false)
    renderUi(GAME.UI)
    rhiEnableDepthTest(true)

    rhiSwapBuffers()

}