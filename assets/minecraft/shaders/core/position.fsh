#version 150

#moj_import <minecraft:fog.glsl>

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;

out vec4 fragColor;

void main() {
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);
}
