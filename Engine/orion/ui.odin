package orion

import "core:fmt"
import "core:os"
import "core:time"
import "core:unicode/utf8"
import mui "vendor:microui"
import nvg "vendor:nanovg"
import nvg_gl "vendor:nanovg/gl"
import "vendor:glfw"

UI :: struct {
    ctx: ^mui.Context,
    vg: ^nvg.Context,
    font_id: int,
    profiler: Frame_Profiler,
}

Frame_Profiler :: struct {
    samples: [120]time.Duration,
    sample_index: int,
    sample_sum: time.Duration,
    frame_dt: time.Duration,
    fps: f64,
    mspf: f64,
    last_update: time.Time,
}

ui_text_owner: ^UI

createUi :: proc() -> ^UI {
    ui := new(UI)
    ui.ctx = new(mui.Context)
    mui.init(ui.ctx)
    initFrameProfiler(&ui.profiler)
    return ui
}

initUiRenderer :: proc(ui: ^UI) {
    if ui == nil || ui.ctx == nil {
        return
    }
    if ui.vg != nil {
        return
    }

    ui.vg = nvg_gl.Create({.ANTI_ALIAS, .STENCIL_STROKES})
    if ui.vg == nil {
        fmt.eprintln("Failed to initialize NanoVG context for debug UI")
        return
    }

    font_candidates := []string{
        "C:\\Windows\\Fonts\\consola.ttf",
        "C:\\Windows\\Fonts\\segoeui.ttf",
        "C:\\Windows\\Fonts\\arial.ttf",
    }

    for path in font_candidates {
        if os.exists(path) {
            ui.font_id = nvg.CreateFont(ui.vg, "orion_debug", path)
            if ui.font_id >= 0 {
                break
            }
        }
    }

    if ui.font_id < 0 {
        fmt.eprintln("No usable system font found for debug UI text")
    }

    setupUi(ui.ctx)
    ui_text_owner = ui
}

setupUi :: proc(ctx: ^mui.Context) {
	ctx.text_width = uiTextWidth
	ctx.text_height = uiTextHeight
}

updateUi :: proc(ui: ^UI) {
    if ui == nil || ui.ctx == nil {
        return
    }

    updateFrameProfiler(&ui.profiler)

    window_width, _ := getWindowSize()
    window_w: i32 = 175
    window_h: i32 = 50
    window_x := window_width - window_w - 12
    if window_x < 8 {
        window_x = 8
    }

    mui.begin(ui.ctx)

    window_opts: mui.Options = {.NO_INTERACT, .NO_RESIZE, .NO_SCROLL, .NO_CLOSE, .NO_TITLE}
    // microui keeps container rect in an internal pool; force it every frame
    // so resizing/fullscreen keeps this overlay anchored to top-right.
    profiler_rect := mui.Rect{window_x, 12, window_w, window_h}
    if profiler_container := mui.get_container(ui.ctx, "Profiler", window_opts); profiler_container != nil {
        profiler_container.rect = profiler_rect
    }
    if mui.begin_window(ui.ctx, "Profiler", profiler_rect, window_opts) {
        mui.layout_row(ui.ctx, []i32{-1}, 0)

        frame_ms := 1000.0 * time.duration_seconds(ui.profiler.frame_dt)
        mui.label(ui.ctx, fmt.tprintf("FPS: %.1f", ui.profiler.fps))
        mui.label(ui.ctx, fmt.tprintf("Frame: %.3f ms", frame_ms))
        //mui.label(ui.ctx, fmt.tprintf("Avg: %.3f ms", ui.profiler.mspf))
        //mui.label(ui.ctx, fmt.tprintf("Delta: %v", ui.profiler.frame_dt))

        mui.end_window(ui.ctx)
    }

    mui.end(ui.ctx)
}

renderUi :: proc(ui: ^UI) {
    if ui == nil || ui.ctx == nil || ui.vg == nil {
        return
    }

    win_w, win_h := getWindowSize()
    fb_w, _ := getFramebufferSize()

    device_px_ratio: f32 = 1.0
    if win_w > 0 {
        device_px_ratio = f32(fb_w) / f32(win_w)
    }

    nvg.BeginFrame(ui.vg, f32(win_w), f32(win_h), device_px_ratio)
    if ui.font_id >= 0 {
        nvg.FontFaceId(ui.vg, ui.font_id)
    }
    nvg.FontSize(ui.vg, 18)
    nvg.TextAlign(ui.vg, .LEFT, .TOP)

    cmd: ^mui.Command
    for mui.next_command(ui.ctx, &cmd) {
        #partial switch c in cmd.variant {
        case ^mui.Command_Clip:
            if c.rect.w > 0 && c.rect.h > 0 {
                nvg.Scissor(ui.vg, f32(c.rect.x), f32(c.rect.y), f32(c.rect.w), f32(c.rect.h))
            } else {
                nvg.ResetScissor(ui.vg)
            }

        case ^mui.Command_Rect:
            nvg.BeginPath(ui.vg)
            nvg.Rect(ui.vg, f32(c.rect.x), f32(c.rect.y), f32(c.rect.w), f32(c.rect.h))
            nvg.FillColor(ui.vg, nvg.RGBA(c.color.r, c.color.g, c.color.b, c.color.a))
            nvg.Fill(ui.vg)

        case ^mui.Command_Text:
            nvg.FillColor(ui.vg, nvg.RGBA(c.color.r, c.color.g, c.color.b, c.color.a))
            nvg.Text(ui.vg, f32(c.pos.x), f32(c.pos.y), c.str)

        case ^mui.Command_Icon:
            nvg.BeginPath(ui.vg)
            nvg.Rect(ui.vg, f32(c.rect.x), f32(c.rect.y), f32(c.rect.w), f32(c.rect.h))
            nvg.FillColor(ui.vg, nvg.RGBA(c.color.r, c.color.g, c.color.b, c.color.a))
            nvg.Fill(ui.vg)

        case ^mui.Command_Jump:
            // Internal command handled by mui.next_command.
        }
    }

    nvg.ResetScissor(ui.vg)
    nvg.EndFrame(ui.vg)
}

uiMouseMove :: proc(x, y: f64) {
    if GAME == nil || GAME.UI == nil || GAME.UI.ctx == nil {
        return
    }
    mui.input_mouse_move(GAME.UI.ctx, i32(x), i32(y))
}

uiMouseButton :: proc(button, action: i32, x, y: f64) {
    if GAME == nil || GAME.UI == nil || GAME.UI.ctx == nil {
        return
    }

    btn: mui.Mouse
    ok := true
    switch button {
    case glfw.MOUSE_BUTTON_LEFT:
        btn = .LEFT
    case glfw.MOUSE_BUTTON_RIGHT:
        btn = .RIGHT
    case glfw.MOUSE_BUTTON_MIDDLE:
        btn = .MIDDLE
    case:
        ok = false
    }

    if !ok {
        return
    }

    if action == glfw.PRESS {
        mui.input_mouse_down(GAME.UI.ctx, i32(x), i32(y), btn)
    } else if action == glfw.RELEASE {
        mui.input_mouse_up(GAME.UI.ctx, i32(x), i32(y), btn)
    }
}

uiScroll :: proc(xoffset, yoffset: f64) {
    if GAME == nil || GAME.UI == nil || GAME.UI.ctx == nil {
        return
    }
    mui.input_scroll(GAME.UI.ctx, i32(xoffset * 30), i32(yoffset * -30))
}

uiTextInput :: proc(codepoint: rune) {
    if GAME == nil || GAME.UI == nil || GAME.UI.ctx == nil {
        return
    }
    if codepoint < 32 {
        return
    }
    encoded, width := utf8.encode_rune(codepoint)
    mui.input_text(GAME.UI.ctx, string(encoded[:width]))
}

uiKeyEvent :: proc(key, action, mods: i32) {
    if GAME == nil || GAME.UI == nil || GAME.UI.ctx == nil {
        return
    }

    mapped: mui.Key
    ok := true
    switch key {
    case glfw.KEY_LEFT_SHIFT, glfw.KEY_RIGHT_SHIFT:
        mapped = .SHIFT
    case glfw.KEY_LEFT_CONTROL, glfw.KEY_RIGHT_CONTROL:
        mapped = .CTRL
    case glfw.KEY_LEFT_ALT, glfw.KEY_RIGHT_ALT:
        mapped = .ALT
    case glfw.KEY_BACKSPACE:
        mapped = .BACKSPACE
    case glfw.KEY_DELETE:
        mapped = .DELETE
    case glfw.KEY_ENTER, glfw.KEY_KP_ENTER:
        mapped = .RETURN
    case glfw.KEY_LEFT:
        mapped = .LEFT
    case glfw.KEY_RIGHT:
        mapped = .RIGHT
    case glfw.KEY_HOME:
        mapped = .HOME
    case glfw.KEY_END:
        mapped = .END
    case glfw.KEY_A:
        mapped = .A
    case glfw.KEY_X:
        mapped = .X
    case glfw.KEY_C:
        mapped = .C
    case glfw.KEY_V:
        mapped = .V
    case:
        ok = false
    }

    if !ok {
        return
    }

    _ = mods
    if action == glfw.PRESS {
        mui.input_key_down(GAME.UI.ctx, mapped)
    } else if action == glfw.RELEASE {
        mui.input_key_up(GAME.UI.ctx, mapped)
    }
}

initFrameProfiler :: proc(stats: ^Frame_Profiler) {
    if stats == nil {
        return
    }
    now := time.now()
    stats.last_update = now
    stats.frame_dt = 0
}

updateFrameProfiler :: proc(stats: ^Frame_Profiler) {
    if stats == nil {
        return
    }

    now := time.now()
    dt := time.diff(stats.last_update, now)
    stats.last_update = now
    stats.frame_dt = dt

    stats.sample_sum -= stats.samples[stats.sample_index]
    stats.samples[stats.sample_index] = dt
    stats.sample_sum += dt
    stats.sample_index = (stats.sample_index + 1) % len(stats.samples)

    seconds := time.duration_seconds(stats.sample_sum)
    if seconds > 0 {
        stats.fps = f64(len(stats.samples)) / seconds
        stats.mspf = 1000.0 * seconds / f64(len(stats.samples))
    }
}

uiTextWidth :: proc(font: mui.Font, text: string) -> i32 {
    _ = font
    ui := ui_text_owner
    if ui == nil || ui.vg == nil || ui.font_id < 0 {
        return i32(len(text) * 8)
    }

    nvg.FontFaceId(ui.vg, ui.font_id)
    nvg.FontSize(ui.vg, 18)
    bounds: [4]f32
    nvg.TextBounds(ui.vg, 0, 0, text, &bounds)
    return i32(bounds[2] - bounds[0] + 0.5)
}

uiTextHeight :: proc(font: mui.Font) -> i32 {
    _ = font
    ui := ui_text_owner
    if ui == nil || ui.vg == nil || ui.font_id < 0 {
        return 18
    }

    nvg.FontFaceId(ui.vg, ui.font_id)
    nvg.FontSize(ui.vg, 18)
    _, _, line_height := nvg.TextMetrics(ui.vg)
    if line_height <= 0 {
        return 18
    }
    return i32(line_height + 0.5)
}

getFramebufferSize :: proc() -> (width, height: i32) {
    if GAME == nil || GAME.WINDOW == nil {
        return 1, 1
    }
    w, h := glfw.GetFramebufferSize(GAME.WINDOW)
    width = i32(w)
    height = i32(h)
    if width <= 0 {
        width = 1
    }
    if height <= 0 {
        height = 1
    }
    return
}

getWindowSize :: proc() -> (width, height: i32) {
    if GAME == nil || GAME.WINDOW == nil {
        return 1, 1
    }
    w, h := glfw.GetWindowSize(GAME.WINDOW)
    width = i32(w)
    height = i32(h)
    if width <= 0 {
        width = 1
    }
    if height <= 0 {
        height = 1
    }
    return
}

destroyUi :: proc(ui: ^UI) {
    if ui == nil {
        return
    }

    if ui.vg != nil {
        nvg_gl.Destroy(ui.vg)
        ui.vg = nil
    }

    if ui_text_owner == ui {
        ui_text_owner = nil
    }

    if ui.ctx != nil {
        free(ui.ctx)
        ui.ctx = nil
    }

    free(ui)
}