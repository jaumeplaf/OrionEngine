package orion

import nvg "vendor:nanovg"
import graphicsapis "graphicsapis"

// Backend extension notes:
// 1) Keep this file API-stable and backend-agnostic.
// 2) For Metal/DX11, add `metal*.odin` / `dx11*.odin` implementations with the
//    same function signatures used below.
// 3) Implement every `case .Metal, .DX11` branch before enabling those APIs.
// 4) Keep input/window translation in backend files, not gameplay/UI modules.

RenderAPI :: enum {
    OpenGL,
    Metal,
    DX11,
}

RHI_Cursor_Mode :: enum {
    Normal,
    Disabled,
}

RHI_Input_Action :: enum {
    Press,
    Release,
    Repeat,
}

RHI_Mouse_Button :: enum {
    Left,
    Right,
    Middle,
    Other,
}

RHI_Key :: enum {
    Unknown,
    K0,
    Escape,
    W,
    S,
    A,
    D,
    Space,
    LeftShift,
    LeftControl,
    RightShift,
    RightControl,
    LeftAlt,
    RightAlt,
    Backspace,
    Delete,
    Enter,
    KpEnter,
    Left,
    Right,
    Home,
    End,
    X,
    C,
    V,
}

RHI_Primitive :: enum {
    Triangles,
    Lines,
}

Key_Handler :: proc(key: RHI_Key, action: RHI_Input_Action, mods: i32)
Mouse_Button_Handler :: proc(button: RHI_Mouse_Button, action: RHI_Input_Action)
Cursor_Position_Handler :: proc(x, y: f64)
Scroll_Handler :: proc(xoffset, yoffset: f64)
Resize_Handler :: proc(width, height: i32)
Text_Handler :: proc(codepoint: rune)

key_handler: Key_Handler
mouse_button_handler: Mouse_Button_Handler
cursor_position_handler: Cursor_Position_Handler
scroll_handler: Scroll_Handler
resize_handler: Resize_Handler
text_handler: Text_Handler

setInputHandlers :: proc(
    key_h: Key_Handler,
    mouse_h: Mouse_Button_Handler,
    cursor_h: Cursor_Position_Handler,
    scroll_h: Scroll_Handler,
    resize_h: Resize_Handler,
    text_h: Text_Handler,
) {
    key_handler = key_h
    mouse_button_handler = mouse_h
    cursor_position_handler = cursor_h
    scroll_handler = scroll_h
    resize_handler = resize_h
    text_handler = text_h
}

dispatchKey :: proc(key: RHI_Key, action: RHI_Input_Action, mods: i32) {
    if key_handler != nil {
        key_handler(key, action, mods)
    }
}

dispatchMouseButton :: proc(button: RHI_Mouse_Button, action: RHI_Input_Action) {
    if mouse_button_handler != nil {
        mouse_button_handler(button, action)
    }
}

dispatchCursorPosition :: proc(x, y: f64) {
    if cursor_position_handler != nil {
        cursor_position_handler(x, y)
    }
}

dispatchScroll :: proc(xoffset, yoffset: f64) {
    if scroll_handler != nil {
        scroll_handler(xoffset, yoffset)
    }
}

dispatchResize :: proc(width, height: i32) {
    if resize_handler != nil {
        resize_handler(width, height)
    }
}

dispatchText :: proc(codepoint: rune) {
    if text_handler != nil {
        text_handler(codepoint)
    }
}

rhiOnKeyRaw :: proc(key, action, mods: i32) {
    dispatchKey(RHI_Key(key), RHI_Input_Action(action), mods)
}

rhiOnMouseButtonRaw :: proc(button, action: i32) {
    dispatchMouseButton(RHI_Mouse_Button(button), RHI_Input_Action(action))
}

rhiOnCursorPositionRaw :: proc(x, y: f64) {
    dispatchCursorPosition(x, y)
}

rhiOnScrollRaw :: proc(xoffset, yoffset: f64) {
    dispatchScroll(xoffset, yoffset)
}

rhiOnResizeRaw :: proc(width, height: i32) {
    dispatchResize(width, height)
}

rhiOnTextRaw :: proc(codepoint: rune) {
    dispatchText(codepoint)
}

ACTIVE_RENDER_API: RenderAPI = .OpenGL

setRenderAPI :: proc(api: RenderAPI) {
    ACTIVE_RENDER_API = api
}

getRenderAPI :: proc() -> RenderAPI {
    return ACTIVE_RENDER_API
}

rhiInitWindow :: proc(width, height: i32, title: cstring, major, minor: i32) -> bool {
    // Metal/DX11: create backend-compatible surface/context here and register the same
    // generic input callbacks as OpenGL so higher layers stay backend-agnostic.
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        setInputHandlers(
            handleKeyInput,
            handleMouseButtonInput,
            handleCursorPositionInput,
            handleScrollInput,
            handleFramebufferResize,
            handleTextInput,
        )
        graphicsapis.setInputHandlersRaw(
            rhiOnKeyRaw,
            rhiOnMouseButtonRaw,
            rhiOnCursorPositionRaw,
            rhiOnScrollRaw,
            rhiOnResizeRaw,
            rhiOnTextRaw,
        )
        ok := graphicsapis.openglInitWindow(width, height, title, major, minor)
        return ok
    case .Metal, .DX11:
        return false
    }

    return false
}

rhiGetFramebufferSize :: proc() -> (width, height: i32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        return graphicsapis.openglGetFramebufferSize()
    case .Metal, .DX11:
        return 0, 0
    }

    return 0, 0
}

rhiGetWindowSize :: proc() -> (width, height: i32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        return graphicsapis.openglGetWindowSize()
    case .Metal, .DX11:
        return 0, 0
    }

    return 0, 0
}

rhiSetCursorMode :: proc(mode: RHI_Cursor_Mode) {
    // Metal/DX11: map these modes to platform APIs on your target OS.
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglSetCursorMode(i32(mode))
    case .Metal, .DX11:
    }
}

rhiCreateUiContext :: proc() -> ^nvg.Context {
    // Metal/DX11: return UI renderer context backed by that API.
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        return graphicsapis.openglCreateUiContext()
    case .Metal, .DX11:
        return nil
    }

    return nil
}

rhiDestroyUiContext :: proc(ctx: ^nvg.Context) {
    // Metal/DX11: destroy backend-specific UI context here.
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglDestroyUiContext(ctx)
    case .Metal, .DX11:
    }
}

rhiPollEvents :: proc() {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglPollEvents()
    case .Metal, .DX11:
    }
}

rhiWindowShouldClose :: proc() -> bool {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        return graphicsapis.openglWindowShouldClose()
    case .Metal, .DX11:
        return false
    }

    return false
}

rhiSwapBuffers :: proc() {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglSwapBuffers()
    case .Metal, .DX11:
    }
}

rhiShutdownWindow :: proc() {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglShutdownWindow()
        GAME.WINDOW = nil
    case .Metal, .DX11:
    }
}

rhiLoadFunctions :: proc(major, minor: i32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglLoadFunctions(major, minor)
    case .Metal, .DX11:
        // Backends not implemented yet.
    }
}

rhiSetViewport :: proc(x, y, width, height: i32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglSetViewport(x, y, width, height)
    case .Metal, .DX11:
    }
}

rhiEnableDepthTest :: proc(enable: bool) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglEnableDepthTest(enable)
    case .Metal, .DX11:
    }
}

rhiSetClearColor :: proc(r, g, b, a: f32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglSetClearColor(r, g, b, a)
    case .Metal, .DX11:
    }
}

rhiBeginFrame :: proc() {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglBeginFrame()
    case .Metal, .DX11:
    }
}

rhiCreateShaderProgram :: proc(vertex_path, fragment_path: string) -> (program: u32, success: bool) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        return graphicsapis.openglCreateShaderProgram(vertex_path, fragment_path)
    case .Metal, .DX11:
        return 0, false
    }

    return 0, false
}

rhiDestroyShaderProgram :: proc(program: u32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglDestroyShaderProgram(program)
    case .Metal, .DX11:
    }
}

rhiGetUniformLocation :: proc(program: u32, name: cstring) -> i32 {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        return graphicsapis.openglGetUniformLocation(program, name)
    case .Metal, .DX11:
        return -1
    }

    return -1
}

rhiUseProgram :: proc(program: u32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglUseProgram(program)
    case .Metal, .DX11:
    }
}

rhiSetUniformMat4 :: proc(location: i32, mat_data: ^f32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglSetUniformMat4(location, mat_data)
    case .Metal, .DX11:
    }
}

rhiSetUniformVec4 :: proc(location: i32, vec_data: ^f32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglSetUniformVec4(location, vec_data)
    case .Metal, .DX11:
    }
}

rhiCreateMeshBuffers :: proc(vertices: []f32, indices: []u16) -> (vao, vbo, ebo: u32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        return graphicsapis.openglCreateMeshBuffers(vertices, indices)
    case .Metal, .DX11:
        return 0, 0, 0
    }

    return 0, 0, 0
}

rhiDestroyMeshBuffers :: proc(vao, vbo, ebo: ^u32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglDestroyMeshBuffers(vao, vbo, ebo)
    case .Metal, .DX11:
    }
}

rhiBindVertexArray :: proc(vao: u32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglBindVertexArray(vao)
    case .Metal, .DX11:
    }
}

rhiSetLineWidth :: proc(width: f32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglSetLineWidth(width)
    case .Metal, .DX11:
    }
}

rhiDrawIndexed :: proc(primitive: RHI_Primitive, index_count: i32) {
    switch ACTIVE_RENDER_API {
    case .OpenGL:
        graphicsapis.openglDrawIndexed(i32(primitive), index_count)
    case .Metal, .DX11:
    }
}
