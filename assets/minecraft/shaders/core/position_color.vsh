#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;

layout(location = 0) out vec4 vertexColor;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexColor = Color;

    if (ProjMat[3][3] == 0.0) {
        // Seemingly the only other object rendered by this shader is the debug pie.
        // Since that's a GUI element, we can check for whether the projection matrix is orthographic or not.
        gl_Position = vec4(-1.0);
        return;
    }
}
