package engine

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import m "core:math/linalg/glsl"
import "vendor:glfw"
import "orion"

main :: proc() {
    //Initialize pre-game
    fmt.println("Main started")
    orion.construct(800, 600)
    fmt.println("Construct done")
    //Get scene entities
    scene01 := initScene01()
    fmt.println("Scene initialized")
    //Run game loop
    orion.run(&scene01)
}

initScene01 :: proc() -> orion.Scene {
    //Initialize managers and scene
    entity_manager01 : orion.EntityManager
    component_manager01 : orion.ComponentManager
    event_manager01 : orion.EventManager
    
    scene01 := orion.initScene("Scene 01", &entity_manager01, &component_manager01, &event_manager01)
    
    //Initialize camera
    camera01 := orion.initCamera( //ID: 0
        &component_manager01,   //manager
        &entity_manager01,      //entities
        70.0,                   //fov
        m.vec3{0.0, 0.0, 10.0},  //position
        m.vec3{0.0, 0.0, 0.0}   //target
    )
    fmt.println("Camera initialized")
    //Initialize shaders
    sha_base01 := orion.initShader("vertex.glsl", "fragment.glsl")
    fmt.println("Shaders initialized")
    //Initialize materials
    mat_red01 := orion.initMaterial(&sha_base01, m.vec3{1.0, 0.0, 0.0})
    
    //Initialize entities
    cube01 := orion.initStaticMesh(
        &component_manager01,  //manager
        &entity_manager01,     //entities
        orion.s_cube,                //mesh
        mat_red01              //material
    )

    return scene01
}