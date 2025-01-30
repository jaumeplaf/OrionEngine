package orion

import "core:fmt"

Shape :: struct {
    vertices: []f32,
    indices: []u16
}

s_triangle := Shape{
    vertices = []f32{
        0.0,  0.5, 0.0,
        0.5, -0.5, 0.0,
       -0.5, -0.5, 0.0
    },
    indices = []u16{
        0, 1, 2
    },
}

s_plane := Shape{
    vertices = []f32{
        -0.5, 0.0, 0.5,
         0.5, 0.0, 0.5,
         0.5, 0.0,-0.5,
        -0.5, 0.0,-0.5
    },
    indices = []u16{
        0, 1, 2, 
        0, 2, 3
    },
}

s_cube := Shape{
    vertices = []f32 {
        // Positions
        -0.5, -0.5, -0.5,
         0.5, -0.5, -0.5,
         0.5,  0.5, -0.5,
        -0.5,  0.5, -0.5,
        -0.5, -0.5,  0.5,
         0.5, -0.5,  0.5,
         0.5,  0.5,  0.5,
        -0.5,  0.5,  0.5,
    },
    indices = []u16 {
        //indices
        0, 1, 2, 2, 3, 0, // Front face
        4, 5, 6, 6, 7, 4, // Back face
        0, 1, 5, 5, 4, 0, // Bottom face
        2, 3, 7, 7, 6, 2, // Top face
        0, 3, 7, 7, 4, 0, // Left face
        1, 2, 6, 6, 5, 1, // Right face
    }
}
