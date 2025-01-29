package engine

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import "vendor:glfw"

WIDTH :: 800
HEIGHT :: 600

main :: proc() {
    // Initialize GLFW (similar to WebGL canvas context creation)
    if glfw.Init() != true {
        fmt.eprintln("Failed to initialize GLFW")
        return
    }
    defer glfw.Terminate()

    // Window hints (similar to WebGL context attributes)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    when ODIN_OS == .Darwin {  // Needed for macOS
        glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, 1)
    }

    // Create window (like creating a canvas element in WebGL)
    window := glfw.CreateWindow(WIDTH, HEIGHT, "Odin OpenGL Cube", nil, nil)
    if window == nil {
        fmt.eprintln("Failed to create GLFW window")
        return
    }
    defer glfw.DestroyWindow(window)

    glfw.MakeContextCurrent(window)
    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

    // Load OpenGL functions (automatic in WebGL, explicit here)
    gl.load_up_to(3, 3, glfw.gl_set_proc_address)

    shader_dir := os.get_current_directory() // Get executable's directory

    when ODIN_OS == .Darwin || ODIN_OS == .Linux  { // macOS uses forward slashes
        vert_path := fmt.tprintf("%s/shaders/vertex.glsl", shader_dir)
        frag_path := fmt.tprintf("%s/shaders/fragment.glsl", shader_dir)
    } 
    else { // Windows uses backslashes
        vert_path := fmt.tprintf("%s\\shaders\\vertex.glsl", shader_dir)
        frag_path := fmt.tprintf("%s\\shaders\\fragment.glsl", shader_dir)
    }

    if !os.exists(vert_path) {
        fmt.eprintln("Vertex shader not found at:", vert_path)
        return
    }
    if !os.exists(frag_path) {
        fmt.eprintln("Fragment shader not found at:", frag_path)
        return
    }
    
    program, ok := gl.load_shaders_file(vert_path, frag_path)
    if !ok {
        fmt.eprintln("Failed to load shaders at path:", vert_path, frag_path)
        return
    }
    fmt.println(vert_path, frag_path)
    defer gl.DeleteProgram(program)

    // Cube data (similar to WebGL buffer creation)
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

    // VAO/VBO setup (like WebGL vertex array objects)
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
    for !glfw.WindowShouldClose(window) {
        // Input
        process_input(window)

        // Render
        gl.ClearColor(0.5, 0.5, 0.5, 1.0)  // 50% gray background
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        gl.Enable(gl.DEPTH_TEST)

        gl.UseProgram(program)
        gl.BindVertexArray(vao)
        gl.DrawElements(gl.TRIANGLES, 36, gl.UNSIGNED_SHORT, nil)

        glfw.SwapBuffers(window)
        glfw.PollEvents()
    }
}

// Callbacks and helpers
framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    gl.Viewport(0, 0, width, height)
}

process_input :: proc(window: glfw.WindowHandle) {
    if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
        glfw.SetWindowShouldClose(window, true)
    }
}