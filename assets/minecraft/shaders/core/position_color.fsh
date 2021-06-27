#version 150

#moj_import <utils.glsl>

in vec4 vertexColor;
in float isHorizon;

uniform vec4 ColorModulator;
uniform vec2 ScreenSize;

out vec4 fragColor;

void main() {
    if (isHorizon > 0.5) {
        gl_FragDepth = 0.5;
        int index = inControl(gl_FragCoord.xy, ScreenSize.x);
        if (index == 26) {
            fragColor = vertexColor * ColorModulator;
            return;
        } else if (index != -1) {
            discard;
        }
    }
    gl_FragDepth = gl_FragCoord.z;
    
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}
