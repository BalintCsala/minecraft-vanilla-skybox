#version 150

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;

uniform sampler2D Sampler0;

out vec2 texCoord0;
out vec4 vertexColor;

out float isSun;

out vec4 vertex1;
out vec4 vertex2;
out vec4 vertex3;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    texCoord0 = UV0;
    vertexColor = Color;

    ivec2 texSize = textureSize(Sampler0, 0);
    isSun = (abs(texelFetch(Sampler0, ivec2(16), 0).a * 255.0 - 17.0) < 0.5) ? 1.0 : 0.0;

    vertex1 = vec4(0.0, 0.0, 0.0, 0.0);
    vertex2 = vec4(0.0, 0.0, 0.0, 0.0);
    vertex3 = vec4(0.0, 0.0, 0.0, 0.0);

    if (isSun < 0.5) {
        return;
    }

    int id = gl_VertexID % 4;
    switch(id) {
        case 0:
            gl_Position = vec4(-2.0, 10.0, 0.0, 1.0);
            vertex1 = vec4(Position, 1.0);
            break;
        case 1:
            gl_Position = vec4(-2.0, -2.0, 0.0, 1.0);
            vertex2 = vec4(Position, 1.0);
            break;
        case 2:
            gl_Position = vec4(10.0, -2.0, 0.0, 1.0);
            vertex3 = vec4(Position, 1.0);
            break;
        case 3:
            gl_Position = vec4(10.0, -2.0, 0.0, 1.0);
            break;
    }
}
