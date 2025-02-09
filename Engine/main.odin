package engine

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import m "core:math/linalg/glsl"
import "vendor:glfw"
import "orion"


main :: proc() {
    
    orion.initGL(800, 600)
    fmt.println("OpenGL initialized")
    //sha_flat01 := orion.initShader("vertex.glsl", "fragment.glsl")
    //m_flat01 := orion.Material{&sha_flat01, m.vec4{0.39, 0.58, 0.93, 1.0}}
    //sm_cube01 := orion.initStaticMesh(orion.s_cube, m_flat01)
    //objects := []orion.StaticMesh{sm_cube01}

    scene := initScene01()
    fmt.println("Scene initialized")

    orion.debugScene(&scene) //pass scene pointer to debug
    fmt.println("Scene debugged")

    orion.gameLoop(&scene) //pass scene pointer to game loop
}

initScene01 :: proc() -> orion.Scene {
    fmt.println("Initializing entity manager")
    entity_manager := orion.initEntityManager()
    fmt.println("Entity manager initialized")

    fmt.println("Initializing component manager")
    component_manager := orion.initComponentManager()
    fmt.println("Component manager initialized")

    fmt.println("Initializing scene")
    current_scene := orion.initScene("Scene01", entity_manager, component_manager)
    fmt.println("Scene initialized")

    fmt.println("Creating entities")
    ent0 := orion.entityCreate(entity_manager)
    fmt.println("Entity 0 created")
    ent1 := orion.entityCreate(entity_manager)
    fmt.println("Entity 1 created")
    ent2 := orion.entityCreate(entity_manager)
    fmt.println("Entity 2 created")
    orion.entityDestroy(&current_scene, ent2)
    fmt.println("Entity 2 destroyed")
    ent3 := orion.entityCreate(entity_manager)
    fmt.println("Entity 3 created")
    ent4 := orion.entityCreate(entity_manager)
    fmt.println("Entity 4 created")
    orion.entityDestroy(&current_scene, ent4)
    fmt.println("Entity 4 destroyed")
    ent5 := orion.entityCreate(entity_manager)
    fmt.println("Entity 5 created")

    fmt.println("Initializing shader and material")
    sha_flat02 := orion.shader("vertex.glsl", "fragment.glsl")
    m_flat02 := orion.Material{sha_flat02, m.vec4{0.39, 0.58, 0.93, 1.0}}
    fmt.println("Shader and material initialized")

    fmt.println("Creating static mesh")
    mesh01 := orion.staticMesh(current_scene, orion.s_cube, m_flat02)
    fmt.println("Static mesh created")

    return current_scene
}