package main

import "core:fmt"
import m "core:math/linalg/glsl"

main :: proc() {
    eye := m.vec3{0,0,10}
    center := m.vec3{0,0,0}
    up := m.vec3{0,1,0}

    view := m.mat4LookAt(eye, center, up)
    proj := m.mat4Perspective(10.0, 2.0, 0.01, 10000.0)
    model := m.mat4Translate(m.vec3{0,0,-5}) * m.mat4Scale(m.vec3{15,15,15})

    pRight := m.vec4{0.5, -0.5, 0, 1}
    pLeft := m.vec4{-0.5, -0.5, 0, 1}

    clipCol_R := proj * view * model * pRight
    clipCol_L := proj * view * model * pLeft

    clipRow_R := pRight * model * view * proj
    clipRow_L := pLeft * model * view * proj

    fmt.println("Col ndcRight x:", clipCol_R.x/clipCol_R.w)
    fmt.println("Col ndcLeft  x:", clipCol_L.x/clipCol_L.w)
    fmt.println("Row ndcRight x:", clipRow_R.x/clipRow_R.w)
    fmt.println("Row ndcLeft  x:", clipRow_L.x/clipRow_L.w)
}
