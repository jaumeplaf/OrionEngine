package orion

import mui "vendor:microui"

UI :: struct {
    ctx : ^mui.Context,
}

createUi :: proc() -> ^UI {
    ui := new(UI)
    ui.ctx = new(mui.Context)
    mui.init(ui.ctx)
    return ui
}

destroyUi :: proc(ui: ^UI) {
    if ui == nil {
        return
    }
    if ui.ctx != nil {
        free(ui.ctx)
        ui.ctx = nil
    }
    free(ui)
}