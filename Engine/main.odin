package engine

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import m "core:math/linalg/glsl"
import "vendor:glfw"
import "orion"

main :: proc() {
    fmt.println("Hellooopeee")
    orion.initGL(800, 400)

    scene := initScene01()

    if orion.GAME.DEBUG{
        orion.debugScene(scene) //pass scene pointer to debug
    } 

    orion.gameLoop(scene) //pass scene pointer to game loop
}

initScene01 :: proc() -> ^orion.Scene {
    current_scene := orion.initScene("Scene01")
    
    //Declare entities, must look at memory management for this
    ent0 := orion.createEntity(current_scene)
    ent1 := orion.createEntity(current_scene)
    ent2 := orion.createEntity(current_scene)
    orion.destroyEntity(current_scene, ent2)
    ent3 := orion.createEntity(current_scene)
    ent4 := orion.createEntity(current_scene)
    orion.destroyEntity(current_scene, ent4)
    ent5 := orion.createEntity(current_scene)
    
    sha_flat02 := orion.createShader("vertex.glsl", "fragment.glsl")
    m_flat02 := orion.Material{sha_flat02, m.vec4{0.39, 0.58, 0.93, 1.0}}
    mesh01 := orion.initStaticMesh(orion.s_triangle, m_flat02)

    orion.translate(mesh01, m.vec3{0,0,0})
    orion.rotate(mesh01, m.vec3{0,0,1}, 45)

    return current_scene
}