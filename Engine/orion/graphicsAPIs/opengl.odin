package graphicsAPIs

import gl "vendor:OpenGL"
import "vendor:glfw"
import nvg "vendor:nanovg"
import nvg_gl "vendor:nanovg/gl"
import "base:runtime"

// OpenGL + GLFW backend implementation used by the engine RHI.

opengl_window: glfw.WindowHandle
opengl_is_fullscreen: bool
opengl_windowed_x: i32
opengl_windowed_y: i32
opengl_windowed_w: i32
opengl_windowed_h: i32

// Raw callback hooks set by package `orion`.
Key_Handler_Raw :: proc(key, action, mods: i32)
Mouse_Button_Handler_Raw :: proc(button, action: i32)
Cursor_Position_Handler_Raw :: proc(x, y: f64)
Scroll_Handler_Raw :: proc(xoffset, yoffset: f64)
Resize_Handler_Raw :: proc(width, height: i32)
Text_Handler_Raw :: proc(codepoint: rune)

key_handler_raw: Key_Handler_Raw
mouse_button_handler_raw: Mouse_Button_Handler_Raw
cursor_position_handler_raw: Cursor_Position_Handler_Raw
scroll_handler_raw: Scroll_Handler_Raw
resize_handler_raw: Resize_Handler_Raw
text_handler_raw: Text_Handler_Raw

setInputHandlersRaw :: proc(
	key_h: Key_Handler_Raw,
	mouse_h: Mouse_Button_Handler_Raw,
	cursor_h: Cursor_Position_Handler_Raw,
	scroll_h: Scroll_Handler_Raw,
	resize_h: Resize_Handler_Raw,
	text_h: Text_Handler_Raw,
) {
	key_handler_raw = key_h
	mouse_button_handler_raw = mouse_h
	cursor_position_handler_raw = cursor_h
	scroll_handler_raw = scroll_h
	resize_handler_raw = resize_h
	text_handler_raw = text_h
}

openglMapInputAction :: proc(action: i32) -> i32 {
	switch action {
	case glfw.PRESS:
		return 0
	case glfw.RELEASE:
		return 1
	case glfw.REPEAT:
		return 2
	}
	return 1
}

openglMapMouseButton :: proc(button: i32) -> i32 {
	switch button {
	case glfw.MOUSE_BUTTON_LEFT:
		return 0
	case glfw.MOUSE_BUTTON_RIGHT:
		return 1
	case glfw.MOUSE_BUTTON_MIDDLE:
		return 2
	}
	return 3
}

openglMapKey :: proc(key: i32) -> i32 {
	switch key {
	case glfw.KEY_0:
		return 1
	case glfw.KEY_ESCAPE:
		return 2
	case glfw.KEY_F11:
		return 3
	case glfw.KEY_W:
		return 4
	case glfw.KEY_S:
		return 5
	case glfw.KEY_A:
		return 6
	case glfw.KEY_D:
		return 7
	case glfw.KEY_SPACE:
		return 8
	case glfw.KEY_LEFT_SHIFT:
		return 9
	case glfw.KEY_LEFT_CONTROL:
		return 10
	case glfw.KEY_RIGHT_SHIFT:
		return 11
	case glfw.KEY_RIGHT_CONTROL:
		return 12
	case glfw.KEY_LEFT_ALT:
		return 13
	case glfw.KEY_RIGHT_ALT:
		return 14
	case glfw.KEY_BACKSPACE:
		return 15
	case glfw.KEY_DELETE:
		return 16
	case glfw.KEY_ENTER:
		return 17
	case glfw.KEY_KP_ENTER:
		return 18
	case glfw.KEY_LEFT:
		return 19
	case glfw.KEY_RIGHT:
		return 20
	case glfw.KEY_HOME:
		return 21
	case glfw.KEY_END:
		return 22
	case glfw.KEY_X:
		return 23
	case glfw.KEY_C:
		return 24
	case glfw.KEY_V:
		return 25
	}
	return 0
}

openglKeyCallback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	_ = window
	_ = scancode
	context = runtime.default_context()
	if key_handler_raw != nil {
		key_handler_raw(openglMapKey(key), openglMapInputAction(action), mods)
	}
}

openglMouseButtonCallback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	_ = window
	_ = mods
	context = runtime.default_context()
	if mouse_button_handler_raw != nil {
		mouse_button_handler_raw(openglMapMouseButton(button), openglMapInputAction(action))
	}
}

openglCursorPositionCallback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
	_ = window
	context = runtime.default_context()
	if cursor_position_handler_raw != nil {
		cursor_position_handler_raw(xpos, ypos)
	}
}

openglScrollCallback :: proc "c" (window: glfw.WindowHandle, xoffset, yoffset: f64) {
	_ = window
	context = runtime.default_context()
	if scroll_handler_raw != nil {
		scroll_handler_raw(xoffset, yoffset)
	}
}

openglFramebufferSizeCallback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	_ = window
	context = runtime.default_context()
	if resize_handler_raw != nil {
		resize_handler_raw(width, height)
	}
}

openglCharCallback :: proc "c" (window: glfw.WindowHandle, codepoint: rune) {
	_ = window
	context = runtime.default_context()
	if text_handler_raw != nil {
		text_handler_raw(codepoint)
	}
}

openglInitWindow :: proc(width, height: i32, title: cstring, major, minor: i32) -> bool {
	if glfw.Init() != true {
		return false
	}

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, major)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, minor)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	when ODIN_OS == .Darwin {
		glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, 1)
	}

	window := glfw.CreateWindow(width, height, title, nil, nil)
	if window == nil {
		glfw.Terminate()
		return false
	}

    opengl_window = window
	opengl_is_fullscreen = false

	wx, wy := glfw.GetWindowPos(window)
	ww, wh := glfw.GetWindowSize(window)
	opengl_windowed_x = i32(wx)
	opengl_windowed_y = i32(wy)
	opengl_windowed_w = i32(ww)
	opengl_windowed_h = i32(wh)

	glfw.MakeContextCurrent(window)

	glfw.SetKeyCallback(window, openglKeyCallback)
	glfw.SetMouseButtonCallback(window, openglMouseButtonCallback)
	glfw.SetScrollCallback(window, openglScrollCallback)
	glfw.SetCursorPosCallback(window, openglCursorPositionCallback)
	glfw.SetCharCallback(window, openglCharCallback)
	glfw.SetFramebufferSizeCallback(window, openglFramebufferSizeCallback)
	glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_NORMAL)

	openglLoadFunctions(major, minor)
	return true
}

openglGetFramebufferSize :: proc() -> (width, height: i32) {
	if opengl_window == nil {
		return 0, 0
	}
	width_c, height_c := glfw.GetFramebufferSize(opengl_window)
	return i32(width_c), i32(height_c)
}

openglGetWindowSize :: proc() -> (width, height: i32) {
	if opengl_window == nil {
		return 0, 0
	}
	width_c, height_c := glfw.GetWindowSize(opengl_window)
	return i32(width_c), i32(height_c)
}

openglSetCursorMode :: proc(mode: i32) {
	if opengl_window == nil {
		return
	}

	glfw_mode: i32 = glfw.CURSOR_NORMAL
	if mode == 1 {
		glfw_mode = glfw.CURSOR_DISABLED
	}
	glfw.SetInputMode(opengl_window, glfw.CURSOR, glfw_mode)
}

openglCreateUiContext :: proc() -> ^nvg.Context {
	return nvg_gl.Create({.ANTI_ALIAS, .STENCIL_STROKES})
}

openglDestroyUiContext :: proc(ctx: ^nvg.Context) {
	if ctx != nil {
		nvg_gl.Destroy(ctx)
	}
}

openglPollEvents :: proc() {
	glfw.PollEvents()
}

openglWindowShouldClose :: proc() -> bool {
	if opengl_window == nil {
		return true
	}
	return glfw.WindowShouldClose(opengl_window) == true
}

openglSwapBuffers :: proc() {
	if opengl_window != nil {
		glfw.SwapBuffers(opengl_window)
	}
}

openglToggleFullscreen :: proc() {
	if opengl_window == nil {
		return
	}

	if !opengl_is_fullscreen {
		wx, wy := glfw.GetWindowPos(opengl_window)
		ww, wh := glfw.GetWindowSize(opengl_window)
		opengl_windowed_x = i32(wx)
		opengl_windowed_y = i32(wy)
		opengl_windowed_w = i32(ww)
		opengl_windowed_h = i32(wh)

		monitor := glfw.GetPrimaryMonitor()
		if monitor == nil {
			return
		}

		mode := glfw.GetVideoMode(monitor)
		if mode == nil {
			return
		}

		glfw.SetWindowMonitor(opengl_window, monitor, 0, 0, mode.width, mode.height, mode.refresh_rate)
		opengl_is_fullscreen = true
	} else {
		restore_w := opengl_windowed_w
		restore_h := opengl_windowed_h
		if restore_w <= 0 {
			restore_w = 1280
		}
		if restore_h <= 0 {
			restore_h = 720
		}

		glfw.SetWindowMonitor(opengl_window, nil, opengl_windowed_x, opengl_windowed_y, restore_w, restore_h, 0)
		opengl_is_fullscreen = false
	}
}

openglShutdownWindow :: proc() {
	if opengl_window != nil {
		glfw.DestroyWindow(opengl_window)
		opengl_window = nil
	}
	glfw.Terminate()
}

openglLoadFunctions :: proc(major, minor: i32) {
	gl.load_up_to(int(major), int(minor), glfw.gl_set_proc_address)
}

openglSetViewport :: proc(x, y, width, height: i32) {
	gl.Viewport(x, y, width, height)
}

openglEnableDepthTest :: proc(enable: bool) {
	if enable {
		gl.Enable(gl.DEPTH_TEST)
	} else {
		gl.Disable(gl.DEPTH_TEST)
	}
}

openglSetClearColor :: proc(r, g, b, a: f32) {
	gl.ClearColor(r, g, b, a)
}

openglBeginFrame :: proc() {
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

openglCreateShaderProgram :: proc(vertex_path, fragment_path: string) -> (program: u32, success: bool) {
	return gl.load_shaders_file(vertex_path, fragment_path)
}

openglDestroyShaderProgram :: proc(program: u32) {
	gl.DeleteProgram(program)
}

openglGetUniformLocation :: proc(program: u32, name: cstring) -> i32 {
	return gl.GetUniformLocation(program, name)
}

openglUseProgram :: proc(program: u32) {
	gl.UseProgram(program)
}

openglSetUniformMat4 :: proc(location: i32, mat_data: ^f32) {
	gl.UniformMatrix4fv(location, 1, false, mat_data)
}

openglSetUniformVec4 :: proc(location: i32, vec_data: ^f32) {
	gl.Uniform4fv(location, 1, vec_data)
}

openglCreateMeshBuffers :: proc(vertices: []f32, indices: []u16) -> (vao, vbo, ebo: u32) {
	gl.GenVertexArrays(1, &vao)
	gl.GenBuffers(1, &vbo)
	gl.GenBuffers(1, &ebo)

	gl.BindVertexArray(vao)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(f32), raw_data(vertices), gl.STATIC_DRAW)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices) * size_of(u16), raw_data(indices), gl.STATIC_DRAW)

	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	return vao, vbo, ebo
}

openglDestroyMeshBuffers :: proc(vao, vbo, ebo: ^u32) {
	gl.DeleteVertexArrays(1, vao)
	gl.DeleteBuffers(1, vbo)
	gl.DeleteBuffers(1, ebo)
}

openglBindVertexArray :: proc(vao: u32) {
	gl.BindVertexArray(vao)
}

openglSetLineWidth :: proc(width: f32) {
	gl.LineWidth(width)
}

openglPrimitiveToGL :: proc(primitive: i32) -> u32 {
	switch primitive {
	case 0:
		return gl.TRIANGLES
	case 1:
		return gl.LINES
	}
	return gl.TRIANGLES
}

openglDrawIndexed :: proc(primitive: i32, index_count: i32) {
	gl.DrawElements(openglPrimitiveToGL(primitive), index_count, gl.UNSIGNED_SHORT, nil)
}