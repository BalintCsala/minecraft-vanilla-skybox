#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;

void main() {
    int id = gl_VertexIndex;
    switch (id) {
        case 0:
            gl_Position = vec4(-2.0, 10.0, 0.0, 1.0);
            break;
        case 1:
            gl_Position = vec4(-2.0, -2.0, 0.0, 1.0);
            break;
        case 2:
            gl_Position = vec4(10.0, -2.0, 0.0, 1.0);
            break;
        default:
            gl_Position = vec4(10.0, 10.0, 0.0, 1.0);
            break;
    }
}
