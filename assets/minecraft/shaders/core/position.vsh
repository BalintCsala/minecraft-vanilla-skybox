#version 150

#moj_import <minecraft:fog.glsl>

in vec3 Position;

uniform mat4 ProjMat;
uniform mat4 ModelViewMat;
uniform int FogShape;

out float vertexDistance;

void main() {
    int id = gl_VertexID;
    switch(id) {
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


    vertexDistance = fog_distance(Position, FogShape);
}
