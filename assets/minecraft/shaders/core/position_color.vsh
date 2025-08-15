#version 150

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:light.glsl>

in vec3 Position;
in vec4 Color;

out vec4 vertexColor;

void main() {
    vec4 viewPos = ModelViewMat * vec4(Position, 1.0);
    gl_Position = ProjMat * viewPos;

    if (abs(Light0_Direction) != abs(Light1_Direction)) {
        // Stupid way to detect the horizon
        gl_Position = vec4(-1.0);
        return;
    }
    vertexColor = Color;
}
