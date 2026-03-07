// fragment.glsl
#version 330 core

in vec4 vertexColor;
in vec3 vertexPos;
out vec4 FragColor;
uniform vec4 color;

void main() {
    FragColor = color;
}