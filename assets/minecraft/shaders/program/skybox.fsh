#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D SkyBoxSampler;

in vec2 texCoord;
in vec2 oneTexel;
in vec3 direction;

out vec4 fragColor;

const float FUDGE = 0.0001;

void main(){
    fragColor = texture(DiffuseSampler, texCoord);
	
	if (fragColor.a < 1.0 / 255) {
		float l = max(max(abs(direction.x), abs(direction.y)), abs(direction.z));
		vec3 dir = direction / l;
		
		vec2 skyboxUV;
		vec4 backgroundColor;
		if (dir.x > 1 - FUDGE) {
			skyboxUV = vec2(0, 0.5) + (dir.zy + 1) / 2 / vec2(3, 2);
		} else if (dir.y > 1 - FUDGE) {
			skyboxUV = vec2(0, 0) + (-dir.xz + 1) / 2 / vec2(3, 2);
		} else if (dir.z > 1 - FUDGE) {
			skyboxUV = vec2(1.0 / 3, 0.5) + (dir.xy * vec2(-1, 1) + 1) / 2 / vec2(3, 2);
		} else if (dir.x < -1 + FUDGE) {
			skyboxUV = vec2(2.0 / 3, 0.5) + (dir.zy * vec2(-1, 1) + 1) / 2 / vec2(3, 2);
		} else if (dir.y < -1 + FUDGE) {
			skyboxUV = vec2(1.0 / 3, 0) + (dir.xz * vec2(-1, 1) + 1) / 2 / vec2(3, 2);
		} else {
			skyboxUV = vec2(2.0 / 3, 0) + (dir.xy + 1) / 2 / vec2(3, 2);
		}
	
		fragColor = texture(SkyBoxSampler, skyboxUV);
	}
}
