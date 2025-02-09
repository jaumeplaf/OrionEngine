package orion

import "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

drawSystem :: proc(scene: ^Scene) {
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