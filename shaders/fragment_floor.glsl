// fragment.glsl
#version 330 core

in vec4 vertexColor;
in vec3 vertexPos;
out vec4 FragColor;
uniform vec4 color;

void main() {
    float threshold = 0.98; // ground line width, stay under 1
    float smallMeterLine = 1.0;
    float bigMeterLine = 5.0;
    float halfWidthThreshold = 1.0 - ((1.0 - threshold) * 0.5);
    float bigX;
    float bigZ;
    float smallX;
    float smallZ;
    vec4 fColor;
    vec4 lineCol = vec4(color.rgb * 0.75, 1.0);

    bigX = step(threshold, fract(vertexPos.x / bigMeterLine));
    bigZ = step(threshold, fract(vertexPos.z / bigMeterLine));

    // Minor grid lines use half the major line width.
    smallX = step(halfWidthThreshold, fract(vertexPos.x / smallMeterLine));
    smallZ = step(halfWidthThreshold, fract(vertexPos.z / smallMeterLine));

    float bigMask = clamp(bigX + bigZ, 0.0, 1.0);
    float smallMask = clamp(smallX + smallZ, 0.0, 1.0);
    float s = max(bigMask, smallMask);

    fColor = mix(color, lineCol, s);
    FragColor = fColor;

}