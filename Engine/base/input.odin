package base

import "core:fmt"
import "core:c"
import "base:runtime"
import "vendor:glfw"
import "core:time"

//Event callbacks

keyCallback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	context = runtime.default_context()
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS { EXIT_APPLICATION = true}
	else if key == glfw.KEY_W && action == glfw.PRESS { fmt.println("W pressed") }
	else if key == glfw.KEY_S && action == glfw.PRESS { fmt.println("S pressed") }
	else if key == glfw.KEY_A && action == glfw.PRESS { fmt.println("A pressed") }
	else if key == glfw.KEY_D && action == glfw.PRESS { fmt.println("D pressed") }
	else if key == glfw.KEY_SPACE && action == glfw.PRESS { fmt.println("Space pressed") }
	else if key == glfw.KEY_LEFT_SHIFT && action == glfw.PRESS { fmt.println("Shift pressed") }
	else if key == glfw.KEY_LEFT_CONTROL && action == glfw.PRESS { fmt.println("Ctrl pressed") }
}

mouseCallback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
	context = runtime.default_context()
	fmt.println("Mouse clicked!")
}

cursorPositionCallback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
    context = runtime.default_context()
	//fmt.println("Mouse moved: ", "x-", xpos, "y-", ypos)
}

scrollCallback :: proc "c" (window: glfw.WindowHandle, xoffset, yoffset: f64) {
	context = runtime.default_context()
	fmt.println("Scrolling: ", "x-", xoffset, "y-", yoffset)
}

framebufferSizeCallback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	context = runtime.default_context()
	//fmt.println("Framebuffer resized: ", "w-", width, "h-", height)
	ASPECT_RATIO = getAspectRatio_i32(width, height)
	RESIZE_WINDOW = true //this initializes the RESIZE_WINDOW event	
}