package orion

import "core:fmt"
import "core:os"
import "core:time"
import "core:unicode/utf8"
import mui "vendor:microui"
import nvg "vendor:nanovg"

// UI holds all runtime state for the microui -> NanoVG overlay pipeline.
UI :: struct {
    ctx: ^mui.Context,
    vg: ^nvg.Context,
    font_id: int,
    profiler: Frame_Profiler,
}

// Rolling profiler values used by the top-right debug overlay.
Frame_Profiler :: struct {
    samples: [120]time.Duration,
    sample_index: int,
    sample_sum: time.Duration,
    frame_dt: time.Duration,
    fps: f64,
    mspf: f64,
    last_update: time.Time,
}

// microui text callbacks do not receive a user pointer; keep a global owner.
ui_text_owner: ^UI

// Engine startup allocates microui state and profiler buffers.
createUi :: proc() -> ^UI {
    ui := new(UI)
    ui.ctx = new(mui.Context)
    mui.init(ui.ctx)
    initFrameProfiler(&ui.profiler)
    return ui
}

// Called once after OpenGL context exists. Creates NanoVG renderer + font.
initUiRenderer :: proc(ui: ^UI) {
    if ui == nil || ui.ctx == nil {
        fmt.println("UI context not initialized; cannot create renderer")
        return
    }
    if ui.vg != nil {
        return
    }

    ui.vg = rhiCreateUiContext()
    if ui.vg == nil {
        fmt.eprintln("Failed to initialize NanoVG context for debug UI")
        return
    }

    font_candidates := []string{
        // Windows paths
        "C:\\Windows\\Fonts\\consola.ttf",
        "C:\\Windows\\Fonts\\segoeui.ttf",
        "C:\\Windows\\Fonts\\arial.ttf",
        // macOS paths
        "/System/Library/Fonts/Monaco.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Courier New.ttf",
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

// Wire microui text measurement callbacks.
setupUi :: proc(ctx: ^mui.Context) {
	ctx.text_width = uiTextWidth
	ctx.text_height = uiTextHeight
}

// Build a single microui frame (widgets + layout) each engine frame.
updateUi :: proc(ui: ^UI) {
    if ui == nil || ui.ctx == nil {
        return
    }

    // Refresh frame timing before drawing labels.
    updateFrameProfiler(&ui.profiler)

    window_width, _ := getWindowSize()
    window_w: i32 = 175
    window_h: i32 = 50
    window_x := window_width - window_w - 12
    if window_x < 8 {
        window_x = 8
    }

    mui.begin(ui.ctx)

    // HUD-style window: no title bar, no interaction, fixed size.
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
        // Enable these when you want more telemetry lines.
        // mui.label(ui.ctx, fmt.tprintf("Avg: %.3f ms", ui.profiler.mspf))
        // mui.label(ui.ctx, fmt.tprintf("Delta: %v", ui.profiler.frame_dt))

        mui.end_window(ui.ctx)
    }

    mui.end(ui.ctx)
}

// Render microui command list through NanoVG.
renderUi :: proc(ui: ^UI) {
    if ui == nil || ui.ctx == nil || ui.vg == nil {
        return
    }

    win_w, win_h := getWindowSize()
    fb_w, _ := getFramebufferSize()

    // Keep text sharp on HiDPI displays by matching framebuffer/window ratio.
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

    // Translate microui's draw commands to NanoVG draw calls.
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

// GLFW -> microui mouse motion bridge.
uiMouseMove :: proc(x, y: f64) {
    if GAME == nil || GAME.UI == nil || GAME.UI.ctx == nil {
        return
    }
    mui.input_mouse_move(GAME.UI.ctx, i32(x), i32(y))
}

// GLFW -> microui mouse button bridge.
uiMouseButton :: proc(button: RHI_Mouse_Button, action: RHI_Input_Action, x, y: f64) {
    if GAME == nil || GAME.UI == nil || GAME.UI.ctx == nil {
        return
    }

    btn: mui.Mouse
    ok := true
    #partial switch button {
    case .Left:
        btn = .LEFT
    case .Right:
        btn = .RIGHT
    case .Middle:
        btn = .MIDDLE
    case:
        ok = false
    }

    if !ok {
        return
    }

    if action == .Press {
        mui.input_mouse_down(GAME.UI.ctx, i32(x), i32(y), btn)
    } else if action == .Release {
        mui.input_mouse_up(GAME.UI.ctx, i32(x), i32(y), btn)
    }
}

// GLFW -> microui wheel bridge.
uiScroll :: proc(xoffset, yoffset: f64) {
    if GAME == nil || GAME.UI == nil || GAME.UI.ctx == nil {
        return
    }
    mui.input_scroll(GAME.UI.ctx, i32(xoffset * 30), i32(yoffset * -30))
}

// GLFW character callback receives a rune; convert to UTF-8 for microui.
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

// GLFW -> microui key mapping for navigation/edit shortcuts.
uiKeyEvent :: proc(key: RHI_Key, action: RHI_Input_Action, mods: i32) {
    if GAME == nil || GAME.UI == nil || GAME.UI.ctx == nil {
        return
    }

    mapped: mui.Key
    ok := true
    #partial switch key {
    case .LeftShift, .RightShift:
        mapped = .SHIFT
    case .LeftControl, .RightControl:
        mapped = .CTRL
    case .LeftAlt, .RightAlt:
        mapped = .ALT
    case .Backspace:
        mapped = .BACKSPACE
    case .Delete:
        mapped = .DELETE
    case .Enter, .KpEnter:
        mapped = .RETURN
    case .Left:
        mapped = .LEFT
    case .Right:
        mapped = .RIGHT
    case .Home:
        mapped = .HOME
    case .End:
        mapped = .END
    case .A:
        mapped = .A
    case .X:
        mapped = .X
    case .C:
        mapped = .C
    case .V:
        mapped = .V
    case:
        ok = false
    }

    if !ok {
        return
    }

    _ = mods
    if action == .Press {
        mui.input_key_down(GAME.UI.ctx, mapped)
    } else if action == .Release {
        mui.input_key_up(GAME.UI.ctx, mapped)
    }
}

// Initialize profiler timestamp baseline.
initFrameProfiler :: proc(stats: ^Frame_Profiler) {
    if stats == nil {
        return
    }
    now := time.now()
    stats.last_update = now
    stats.frame_dt = 0
}

// Update instantaneous dt + rolling average FPS/MSPF.
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

// microui callback: estimate/measure text width for layout.
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

// microui callback: return line height used for layout rows.
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

// Query framebuffer pixels (used for DPI ratio and GL viewport logic).
getFramebufferSize :: proc() -> (width, height: i32) {
    if GAME == nil {
        return 1, 1
    }
    width, height = rhiGetFramebufferSize()
    if width <= 0 {
        width = 1
    }
    if height <= 0 {
        height = 1
    }
    return
}

// Query logical window size (used for UI anchoring/layout positions).
getWindowSize :: proc() -> (width, height: i32) {
    if GAME == nil {
        return 1, 1
    }
    width, height = rhiGetWindowSize()
    if width <= 0 {
        width = 1
    }
    if height <= 0 {
        height = 1
    }
    return
}

// Engine shutdown: release NanoVG, microui, and owning UI object.
destroyUi :: proc(ui: ^UI) {
    if ui == nil {
        return
    }

    if ui.vg != nil {
        rhiDestroyUiContext(ui.vg)
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