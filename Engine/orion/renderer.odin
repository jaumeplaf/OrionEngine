package orion

import "core:fmt"
import "core:time"
import m "core:math/linalg/glsl"
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

    //Initialize time
	GAME.START_TIME = time.now()
}

initUniforms :: proc(shader: ^Shader){
	program := shader
    //Init vertex attributes
    //TODO: CHECK IF THIS IS CORRECT/NEEDED
	gl.EnableVertexAttribArray(program.vertex_position)
    gl.EnableVertexAttribArray(program.indices)
    //Init uniforms
    program.model_matrix = gl.GetUniformLocation(program.program, "model_matrix")
    program.view_matrix = gl.GetUniformLocation(program.program, "view_matrix")
    program.projection_matrix = gl.GetUniformLocation(program.program, "projection_matrix")
    program.color = gl.GetUniformLocation(program.program, "color")
}

draw :: proc(entities: ^EntityManager, components: ^ComponentManager, events: ^EventManager) {
    // Render
    gl.ClearColor(0.5, 0.5, 0.5, 1.0)  // 50% gray background
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
    gl.Enable(gl.DEPTH_TEST)

    //Draw all StaticMesh components
	for entity_id, static_mesh in components.static_meshes {
		camera := components.cameras[0]
		material := static_mesh.material
		program := material.shader.program
		gl.UseProgram(program)

		updateUniforms(components, entity_id)

		drawTriangles(static_mesh)
	}
    //Before or after for loop?
    glfw.SwapBuffers(GAME.WINDOW)
    glfw.PollEvents()


}
drawTriangles :: proc (model: StaticMesh) {
	vertices := model.mesh.vertices
	length := i32(len(vertices))
	gl.DrawElements(gl.TRIANGLES, length, gl.UNSIGNED_INT, nil)
}

updateUniforms :: proc(components: ^ComponentManager, id: entity_id){
    mat := components.static_meshes[id].material
    prog := mat.shader 

    updateModelMatrixUniform(components, id)
    updateViewMatrixUniform(components, prog^)
    updateProjectionMatrixUniform(components, prog^)

	//Custom shader uniforms
    gl.Uniform4fv(mat.shader.color, 1, &mat.color[0])
}

updateModelMatrixUniform :: proc(manager: ^ComponentManager, id: entity_id){
    transform := manager.transforms[id]
    model_matrix := transform.model_matrix
    prog := manager.static_meshes[id].material.shader
    gl.UniformMatrix4fv(prog.model_matrix, 1, false, &model_matrix[0][0])
}

updateViewMatrixUniform :: proc(manager : ^ComponentManager, shader: Shader){
    view_matrix := manager.cameras[0].view_matrix
    gl.UniformMatrix4fv(shader.view_matrix, 1, false, &view_matrix[0][0])
}

updateProjectionMatrixUniform :: proc(manager : ^ComponentManager, shader : Shader){
    projection_matrix := manager.cameras[0].projection_matrix
    gl.UniformMatrix4fv(shader.projection_matrix, 1, false, &projection_matrix[0][0])
}

//Needed? Casey Muratori advised agains this kind of thing, let the OS handle it and avoid extra closing time?
cleanup :: proc() {
	glfw.DestroyWindow(GAME.WINDOW)
	glfw.Terminate()
}