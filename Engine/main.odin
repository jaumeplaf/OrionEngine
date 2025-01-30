package engine

import "core:fmt"
import "core:os"
import gl "vendor:OpenGL"
import m "core:math/linalg/glsl"
import "vendor:glfw"
import "orion"


main :: proc() {
    
    orion.initGL(800, 600)
    sha_flat01 := orion.initShader("vertex.glsl", "fragment.glsl")
    m_flat01 := orion.Material{&sha_flat01, m.vec4{0.39, 0.58, 0.93, 1.0}}
    sm_cube01 := orion.initStaticMesh(orion.s_cube, m_flat01)

    objects := []orion.StaticMesh{sm_cube01}

    orion.gameLoop(&objects)
}