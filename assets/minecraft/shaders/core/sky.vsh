#version 150

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;

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
}
