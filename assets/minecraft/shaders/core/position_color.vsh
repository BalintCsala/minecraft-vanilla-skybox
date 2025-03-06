#version 150

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;

void main() {
    vec4 viewPos = ModelViewMat * vec4(Position, 1.0);
    if (viewPos.z > -138.0) {
        gl_Position = vec4(-1.0);
        return;
    }
    gl_Position = ProjMat * viewPos;

    vertexColor = Color;
}
