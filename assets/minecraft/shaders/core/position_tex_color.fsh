#version 150

#moj_import <utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform vec2 ScreenSize;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

in vec2 texCoord0;
in vec4 vertexColor;
in float isHorizon;

out vec4 fragColor;

void main() {
    int index = inControl(gl_FragCoord.xy, ScreenSize.x);
    if (index != -1) {
        if (isHorizon > 0.5) {
            // store ProjMat in control pixels
            if (index >= 5 && index <= 15) {
                int c = (index - 5) / 4;
                int r = (index - 5) - c * 4;
                c = (c == 0 && r == 1) ? c : c + 1;
                fragColor = vec4(encodeFloat(ProjMat[c][r]), 1.0);
            }
            // store ModelViewMat in control pixels
            else if (index >= 16 && index <= 24) {
                int c = (index - 16) / 3;
                int r = (index - 16) - c * 3;
                fragColor = vec4(encodeFloat(ModelViewMat[c][r]), 1.0);
            }
            // store ProjMat[0][0] and ProjMat[1][1] in control pixels
            else if (index >= 3 && index <= 4) {
                fragColor = vec4(encodeFloat(atan(ProjMat[index - 3][index - 3])), 1.0);
            }  
            // blackout control pixels for sunDir so sun can write to them (by default, all pixels are FogColor)
            else {
                fragColor = vec4(0.0, 0.0, 0.0, 1.0);
            }
        } else {
            discard;
        }
    } else {
        if (isHorizon) {
            fragColor = vec4(0, 0, 1, 0);
            return;
        }

        vec4 color = texture(Sampler0, texCoord0) * vertexColor;
        if (color.a < 0.1) {
            discard;
        }
        fragColor = color * ColorModulator;
    }
}
