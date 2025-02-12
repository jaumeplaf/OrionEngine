package orion

import "core:fmt"

getAspectRatio :: proc(width: f32, height: f32) -> f32 {
    return width / height
}

getAspectRatio_i32 :: proc(width: i32, height: i32) -> f32 {
    return f32(width) / f32(height)
}

debugScene :: proc(scene: ^Scene) {
    fmt.printf("=== Scene Debug ===\n")
    fmt.printf("Scene Name: %s\n", scene.name)
    debugEntities(scene^)
    debugComponents(scene^)
    fmt.println("===================")
}

debugEntities :: proc(scene: Scene) {
    entities := scene.entities
    fmt.printf("=== Entity Debug ===\n")
    fmt.printf("Alive entities: %d\n", len(entities.alive))
    fmt.printf("Next ID: %d\n", entities.next_id)
    fmt.printf("Freed IDs: %d\n", len(entities.freed_ids))
    fmt.println("\nActive entities:")
    for id in entities.alive {
        fmt.printf("  [%d]\n", id)
    }
    fmt.println("==================")
}

debugComponents :: proc(scene: Scene) {
    components := scene.components
    fmt.printf("=== Component Debug ===\n")
    fmt.printf("Transforms: %d\n", len(components.transforms))
    fmt.printf("Meshes: %d\n", len(components.meshes))
    fmt.printf("Cameras: %d\n", len(components.cameras))
    fmt.println("=======================")
}

setMousePosition :: proc(x, y: f64){
    GAME.MOUSE_POS = {f32(x), f32(y)}
}