//updateProjectionMatrix -> shaders returning <nil>


package engine

import m "core:math/linalg/glsl"
import "orion"

//cmd+shift+b to build and run

main :: proc() {
    //fmt.println("Hellooopeee")
    orion.initWindow(800, 800)

    scene := initScene01()

    if orion.GAME.DEBUG{
        orion.debugScene(scene) //pass scene pointer to debug
    } 

    orion.gameLoop(scene) //pass scene pointer to game loop
}

createAxisLines :: proc(shader: ^orion.Shader) -> [3]orion.entity_id{
    m_flat_red := orion.createMaterial(shader, m.vec4{1.0, 0.0, 0.0, 1.0})
    m_flat_green := orion.createMaterial(shader, m.vec4{0.0, 1.0, 0.0, 1.0})
    m_flat_blue := orion.createMaterial(shader, m.vec4{0.0, 0.0, 1.0, 1.0})

    x_axis_line := orion.initLineMesh(orion.s_line, m_flat_red)
    orion.translate(x_axis_line, m.vec3{0,0.1,0})
    orion.scaleUniform(x_axis_line, 1000)

    y_axis_line := orion.initLineMesh(orion.s_line, m_flat_green)
    orion.scaleUniform(y_axis_line, 1000)
    orion.rotate(y_axis_line, m.vec3{0,0,1}, 90)

    z_axis_line := orion.initLineMesh(orion.s_line, m_flat_blue)
    orion.translate(z_axis_line, m.vec3{0,0.1,0})
    orion.scaleUniform(z_axis_line, 1000)
    orion.rotate(z_axis_line, m.vec3{0,1,0}, 90)

    return [3]orion.entity_id{x_axis_line, y_axis_line, z_axis_line}
}

createFloorPlane :: proc(shader: ^orion.Shader) -> orion.entity_id {
    m_floor_gray := orion.createMaterial(shader, m.vec4{0.8, 0.8, 0.8, 1.0})
    floor_plane := orion.initStaticMesh(orion.s_plane, m_floor_gray)
    orion.translate(floor_plane, m.vec3{0,0,0})
    orion.scaleUniform(floor_plane, 1000)
    return floor_plane
}

initScene01 :: proc() -> ^orion.Scene {
    //Init scene
    current_scene := orion.initScene("Scene01", 45.0)
    //Init shaders
    sha_vc := orion.createShader("vertex.glsl", "fragment.glsl")
    sha_flat := orion.createShader("vertex.glsl", "fragment_flat.glsl")
    sha_floor := orion.createShader("vertex.glsl", "fragment_floor.glsl")

    //Init materials
    m_vc01 := orion.createMaterial(sha_vc, m.vec4{1.0, 1.0, 1.0, 1.0})
    m_floor_gray := orion.createMaterial(sha_floor, m.vec4{0.8, 0.8, 0.8, 1.0})

    //Init floor plane
    floor_plane := orion.initStaticMesh(orion.s_plane, m_floor_gray)
    orion.translate(floor_plane, m.vec3{0,0,0})
    orion.scaleUniform(floor_plane, 1000)

    //Init axis lines
    axisLines := createAxisLines(sha_flat)

    //Init meshes
    triangle01 := orion.initStaticMesh(orion.s_triangle, m_vc01)
    orion.translate(triangle01, m.vec3{0,0.5,0})
    orion.scaleUniform(triangle01, 1)

    return current_scene
}