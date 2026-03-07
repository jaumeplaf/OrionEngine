// vertex.glsl
#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 model_matrix;
uniform mat4 view_matrix;
uniform mat4 projection_matrix;

out vec4 vertexColor;
out vec3 vertexPos;

void main() {
    //gl_Position = vec4(aPos, 1.0);
    vec4 worldPos = model_matrix * vec4(aPos, 1.0);
    vertexPos = worldPos.xyz;

    gl_Position = projection_matrix * view_matrix * worldPos;

    vertexColor = vec4(aPos, 1.0);
}