// fragment.glsl
#version 330 core

in vec4 vertexColor;
in vec3 vertexPos;
out vec4 FragColor;
uniform vec4 color;

void main() {
    float threshold = 0.98; // stay under 1
    float lineWidth = 1 - threshold;
    float axisWidth = 0.01;
    float meterLine = 2.5;
    float sX;
    float sZ;
    vec4 fColor;
    vec4 lineCol = vec4(color.rgb * 0.75, 1.0);
    float posX;
    float posZ;

    /*
    if(abs(vertexPos.x + lineWidth) < axisWidth){
        FragColor = vec4(0.0, 0.0, 1.0, 1.0);
    }
    else if(abs(vertexPos.z + lineWidth) < axisWidth){
        FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
    else{
    */
        sX = step(threshold, fract(vertexPos.x / meterLine));
        sZ = step(threshold, fract(vertexPos.z / meterLine));
        float s = clamp(sX + sZ, 0.0, 1.0);
        fColor = mix(color, lineCol, s);
        FragColor = fColor;
    //}
}