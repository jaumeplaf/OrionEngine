//updateProjectionMatrix -> shaders returning <nil>


package engine

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import m "core:math/linalg/glsl"
import "vendor:glfw"
import "orion"

//cmd+shift+b to build and run

main :: proc() {
    //fmt.println("Hellooopeee")
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
    sha_flat01 := orion.createShader("vertex.glsl", "fragment.glsl")
    //Init materials
    m_flat01 := orion.createMaterial(sha_flat01, m.vec4{0.39, 0.58, 0.93, 1.0})
    //Init meshes
    triangle01 := orion.initStaticMesh(orion.s_triangle, m_flat01)
    orion.translate(triangle01, m.vec3{0,0,0})
    orion.rotate(triangle01, m.vec3{0,0,1}, 0)
    orion.scale(triangle01, m.vec3{1,1,1})
    cube01 := orion.initStaticMesh(orion.s_cube, m_flat01)
    orion.translate(cube01, m.vec3{25,0,25})
    orion.scale(cube01, m.vec3{2,2,2})
    cube02 := orion.initStaticMesh(orion.s_cube, m_flat01)
    orion.translate(cube02, m.vec3{-25,0,-25})
    orion.scale(cube02, m.vec3{2,2,2})
    cube03 := orion.initStaticMesh(orion.s_cube, m_flat01)
    orion.translate(cube03, m.vec3{25,12.5,25})
    orion.scale(cube03, m.vec3{2,2,2})
    cube04 := orion.initStaticMesh(orion.s_cube, m_flat01)
    orion.translate(cube04, m.vec3{25,-12.5,25})
    cube05 := orion.initStaticMesh(orion.s_cube, m_flat01)
    orion.translate(cube05, m.vec3{-25,12.5,-25})
    orion.scale(cube05, m.vec3{2,2,2})
    cube06 := orion.initStaticMesh(orion.s_cube, m_flat01)
    orion.translate(cube06, m.vec3{-25,-12.5,-25})
    orion.scale(cube06, m.vec3{2,2,2})
    cube07 := orion.initStaticMesh(orion.s_cube, m_flat01)
    orion.translate(cube07, m.vec3{0,0,0})
    orion.scale(cube07, m.vec3{1,1,1})

    return current_scene
}