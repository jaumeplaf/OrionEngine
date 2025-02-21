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
    //Init scene
    current_scene := orion.initScene("Scene01")
    //Init shaders
    sha_flat02 := orion.createShader("vertex.glsl", "fragment.glsl")
    //Init materials
    m_flat02 := orion.Material{sha_flat02, m.vec4{0.39, 0.58, 0.93, 1.0}}
    //Init meshes
    triangle01 := orion.initStaticMesh(orion.s_triangle, m_flat02)
    orion.translate(triangle01, m.vec3{0,0,0})
    orion.rotate(triangle01, m.vec3{0,0,1}, 45)
    orion.scale(triangle01, m.vec3{1,1,10})
    cube01 := orion.initStaticMesh(orion.s_cube, m_flat02)
    orion.translate(cube01, m.vec3{25,0,25})
    orion.scale(cube01, m.vec3{2,2,10})


    return current_scene
}