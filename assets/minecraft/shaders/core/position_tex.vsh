#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec2 UV0;

uniform sampler2D Sampler0;

layout(location = 0) out vec2 texCoord0;
layout(location = 1) out float isSun;

const vec2[] UV_OFFSETS = vec2[](
    vec2(1.0, 1.0),
    vec2(-1.0, 1.0),
    vec2(-1.0, -1.0),
    vec2(1.0, -1.0)
);

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    ivec2 texSize = textureSize(Sampler0, 0);
    vec2 texelSize = 1.0 / vec2(texSize);
    vec2 offsetUV = UV0 + UV_OFFSETS[gl_VertexIndex] * texelSize * 0.5;
    vec4 markerColor = texture(Sampler0, offsetUV);

    isSun = float(distance(markerColor, vec4(255, 0, 255, 123) / 255.0) < 0.01);
    texCoord0 = UV0;

    if (isSun < 0.5) {
        return;
    }

    switch (gl_VertexIndex % 4) {
        case 0:
            gl_Position = vec4(-2.0, 10.0, 0.0, 1.0);
            break;
        case 1:
            gl_Position = vec4(-2.0, -2.0, 0.0, 1.0);
            break;
        case 2:
            gl_Position = vec4(10.0, -2.0, 0.0, 1.0);
            break;
        case 3:
            gl_Position = vec4(10.0, -2.0, 0.0, 1.0);
            break;
    }
}
