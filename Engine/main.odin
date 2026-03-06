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
    //orion.rotate(triangle01, m.vec3{0,0,1}, 0)
    orion.scaleUniform(triangle01, 1)
    /*
    cube07 := orion.initStaticMesh(orion.s_cube, m_flat01)
    orion.translate(cube07, m.vec3{0,0,0})
    orion.scale(cube07, m.vec3{5,5,5})
    orion.rotate(cube07, m.vec3{0,1,0}, 45)
*/
    return current_scene
}