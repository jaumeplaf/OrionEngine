package engine

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import m "core:math/linalg/glsl"
import "vendor:glfw"
import "orion"


main :: proc() {
    
    orion.initGL(800, 600)

    scene := initScene01()

    orion.debugScene(&scene) //pass scene pointer to debug

    orion.gameLoop(&scene) //pass scene pointer to game loop
}

initScene01 :: proc() -> orion.Scene {
    entity_manager := orion.initEntityManager()
    component_manager := orion.initComponentManager()
    current_scene := orion.initScene("Scene01", entity_manager, component_manager)

    ent0 := orion.entityCreate(entity_manager)
    ent1 := orion.entityCreate(entity_manager)
    ent2 := orion.entityCreate(entity_manager)
    orion.entityDestroy(&current_scene, ent2)
    ent3 := orion.entityCreate(entity_manager)
    ent4 := orion.entityCreate(entity_manager)
    orion.entityDestroy(&current_scene, ent4)
    ent5 := orion.entityCreate(entity_manager)

    sha_flat02 := orion.shader("vertex.glsl", "fragment.glsl")
    m_flat02 := orion.Material{sha_flat02, m.vec4{0.39, 0.58, 0.93, 1.0}}
    mesh01 := orion.staticMesh(current_scene, orion.s_cube, m_flat02)

    return current_scene
}
