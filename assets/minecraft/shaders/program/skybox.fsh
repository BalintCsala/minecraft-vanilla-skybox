#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D SkyBoxDaySampler;
uniform sampler2D SkyBoxNightSampler;

in vec2 texCoord;
in vec2 oneTexel;
in vec3 direction;
in float timeOfDay; // 1 - Noon, -1 - Midnight

out vec4 fragColor;

const float FUDGE = 0.001;

vec3 sampleSkybox(sampler2D skyboxSampler, vec3 direction) {
	float l = max(max(abs(direction.x), abs(direction.y)), abs(direction.z));
	vec3 dir = direction / l;
	vec3 absDir = abs(dir);
	
	vec2 skyboxUV;
	vec4 backgroundColor;
	if (absDir.x >= absDir.y && absDir.x > absDir.z) {
		if (dir.x > 0) {
			skyboxUV = vec2(2.0 / 3, 0.5) + (dir.zy * vec2(1, -1) + 1) / 2 / vec2(3, 2);
		} else {
			skyboxUV = vec2(0, 0.5) + (-dir.zy + 1) / 2 / vec2(3, 2);
		}
	} else if (absDir.y >= absDir.z) {
		if (dir.y > 0) {
			skyboxUV = vec2(1.0 / 3, 0) + (dir.xz * vec2(1, -1) + 1) / 2 / vec2(3, 2);
		} else {
			skyboxUV = vec2(0, 0) + (dir.xz + 1) / 2 / vec2(3, 2);
		}
	} else {
		if (dir.z > 0) {
			skyboxUV = vec2(2.0 / 3, 0) + (-dir.xy + 1) / 2 / vec2(3, 2);
		} else {
			skyboxUV = vec2(1.0 / 3, 0.5) + (dir.xy * vec2(1, -1) + 1) / 2 / vec2(3, 2);
		}
	}
	return texture(skyboxSampler, skyboxUV).rgb;
}

void main(){
    fragColor = texture(DiffuseSampler, texCoord);
	
	if (fragColor.a < 1.0 / 255) {
		
		vec3 daySkybox = sampleSkybox(SkyBoxDaySampler, direction);
		vec3 nightSkybox = sampleSkybox(SkyBoxNightSampler, direction);

		float factor = smoothstep(-0.1, 0.1, timeOfDay);

		fragColor = vec4(mix(nightSkybox, daySkybox, factor), 1);
	}
}
