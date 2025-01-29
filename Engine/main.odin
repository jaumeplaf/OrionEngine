package engine

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "base"


main :: proc() {
    
    base.initGL(800, 600)
    sha_flat01 := base.initShader("vertex.glsl", "fragment.glsl")
    
    // Cube data (similar to WebGL buffer creation)
    
    //vertices := base.s_cube.vertices
    //indices := base.s_cube.indices
    vertices := [24]f32 {
        // Positions
        -0.5, -0.5, -0.5,
         0.5, -0.5, -0.5,
         0.5,  0.5, -0.5,
        -0.5,  0.5, -0.5,
        -0.5, -0.5,  0.5,
         0.5, -0.5,  0.5,
         0.5,  0.5,  0.5,
        -0.5,  0.5,  0.5,
    }

    indices := [36]u16 {
        //indices
        0, 1, 2, 2, 3, 0, // Front face
        4, 5, 6, 6, 7, 4, // Back face
        0, 1, 5, 5, 4, 0, // Bottom face
        2, 3, 7, 7, 6, 2, // Top face
        0, 3, 7, 7, 4, 0, // Left face
        1, 2, 6, 6, 5, 1, // Right face
    }
    
    //VAO/VBO setup (like WebGL vertex array objects)
    vao, vbo, ebo: u32
    gl.GenVertexArrays(1, &vao)
    gl.GenBuffers(1, &vbo)
    gl.GenBuffers(1, &ebo)
    defer gl.DeleteVertexArrays(1, &vao)
    defer gl.DeleteBuffers(1, &vbo)
    defer gl.DeleteBuffers(1, &ebo)

    gl.BindVertexArray(vao)

    // Vertex Buffer (like WebGL ARRAY_BUFFER)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

    // Element Buffer (like WebGL ELEMENT_ARRAY_BUFFER)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), &indices, gl.STATIC_DRAW)

    // Position attribute (similar to vertexAttribPointer)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    // Main loop (similar to WebGL render loop)
    for !glfw.WindowShouldClose(base.GAME_WINDOW) {
        // Input
        process_input(base.GAME_WINDOW)

        // Render
        gl.ClearColor(0.5, 0.5, 0.5, 1.0)  // 50% gray background
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        gl.Enable(gl.DEPTH_TEST)

        gl.UseProgram(sha_flat01)
        gl.BindVertexArray(vao)
        gl.DrawElements(gl.TRIANGLES, 36, gl.UNSIGNED_SHORT, nil)

        glfw.SwapBuffers(base.GAME_WINDOW)
        glfw.PollEvents()
    }
}


process_input :: proc(window: glfw.WindowHandle) {
    if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
        glfw.SetWindowShouldClose(window, true)
    }
}