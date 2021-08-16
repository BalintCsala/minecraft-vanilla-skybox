#version 150

#moj_import <fog.glsl>
#moj_import <utils.glsl>

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 glpos;

out vec4 fragColor;

void main() {
	discardControlGLPos(gl_FragCoord.xy, glpos);
    vec4 color = vertexColor * ColorModulator;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
	fragColor = vec4(1, 0, 0, 1);
}
