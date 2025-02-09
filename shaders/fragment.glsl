// fragment.glsl
#version 330 core

in vec4 vertexColor;
out vec4 FragColor;

//location????
//llok up learnopengl

void main() {
    //FragColor = vec4(0.39, 0.58, 0.93, 1.0); // Cornflower blue
    FragColor = vertexColor;
}