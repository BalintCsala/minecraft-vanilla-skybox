#version 150

const float PI = 3.141592654;

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec2 ScreenSize;

in vec2 texCoord0;
in vec4 vertexColor;
in float isSun;
in vec4 vertex1;
in vec4 vertex2;
in vec4 vertex3;

out vec4 fragColor;

vec2 convertToCubemapUV(vec3 direction) {
	float l = max(max(abs(direction.x), abs(direction.y)), abs(direction.z));
	vec3 dir = direction / l;
	vec3 absDir = abs(dir);
	
	vec2 skyboxUV;
	vec4 backgroundColor;
	if (absDir.x >= absDir.y && absDir.x > absDir.z) {
		if (dir.x < 0) {
			return vec2(0, 0.5) + (dir.zy * vec2(-1, -1) + 1) / 2 / vec2(3, 2);
		} else {
			return vec2(2.0 / 3, 0.5) + (-dir.zy * vec2(-1, 1) + 1) / 2 / vec2(3, 2);
		}
	} else if (absDir.y >= absDir.z) {
		if (dir.y > 0) {
			return vec2(1.0 / 3, 0) + (dir.xz * vec2(1, -1) + 1) / 2 / vec2(3, 2);
		} else {
			return vec2(0, 0) + (-dir.xz * vec2(-1, -1) + 1) / 2 / vec2(3, 2);
		}
	} else {
		if (dir.z < 0) {
			return vec2(1.0 / 3, 0.5) + (-dir.xy * vec2(-1, 1) + 1) / 2 / vec2(3, 2);
		} else {
			return vec2(2.0 / 3, 0) + (dir.xy * vec2(-1, -1) + 1) / 2 / vec2(3, 2);
		}
	}
}

void main() {
    if (isSun < 0.5) {
        vec4 color = texture(Sampler0, texCoord0) * vertexColor;
        if (color.a == 0.0) {
            discard;
        }
        fragColor = color * ColorModulator;
        return;
    }
    
    if (gl_PrimitiveID >= 1) {
        discard;
    }

    vec3 pos1 = vertex1.xyz / vertex1.w;
    vec3 pos2 = vertex2.xyz / vertex2.w;
    vec3 pos3 = vertex3.xyz / vertex3.w;
    vec3 center = (pos1 + pos3) * 0.5;
    vec3 pos4 = center + (center - pos1);

    // Remove bobbing from the projection matrix
    mat4 projMat = ProjMat;
    projMat[3].xy = vec2(0.0);

    // Get the fragment position
    vec4 ndcPos = vec4(gl_FragCoord.xy / ScreenSize * 2.0 - 1.0, 0.0, 1.0);
    vec4 temp = inverse(projMat) * ndcPos;
    vec3 viewPos = temp.xyz / temp.w;
    vec3 playerPos = viewPos * mat3(ModelViewMat);
    vec3 rayDir = normalize(playerPos);

    // Figure out which cubemaps to use
    float currentTime = 1.0 - fract(atan(center.x, center.y) / PI * 0.5 + 0.5);
    ivec2 texSize = textureSize(Sampler0, 0);
    ivec2 cubemapSize = ivec2(texSize.x, texSize.x / 3 * 2);
    int cubemapCount = texSize.y / cubemapSize.y;
    int sunSize = texSize.y - cubemapCount * (cubemapSize.y + 1);

    vec2 uv = convertToCubemapUV(rayDir);
    ivec2 relativePixelCoord = ivec2(cubemapSize * uv);

    fragColor = vec4(1.0, 0.0, 1.0, 1.0);
    bool found = false;
    for (int i = 0; i < cubemapCount; i++) {
        int previousIndex = (i - 1 + cubemapCount) % cubemapCount;
        int nextIndex = (i + 1) % cubemapCount;

        float startTime = texelFetch(Sampler0, ivec2(0, sunSize + (1 + cubemapSize.y) * i), 0).r;
        float nextStartTime = texelFetch(Sampler0, ivec2(0, sunSize + (1 + cubemapSize.y) * nextIndex), 0).r;
        float interpolationEndTime = texelFetch(Sampler0, ivec2(1, sunSize + (1 + cubemapSize.y) * i), 0).r;

        if (nextStartTime < startTime) {
            nextStartTime += 1.0;
        }
        if (currentTime < startTime || currentTime > nextStartTime) {
            continue;
        }

        found = true;
        vec3 previousValue = texelFetch(Sampler0, ivec2(0, sunSize + (1 + cubemapSize.y) * previousIndex + 1) + relativePixelCoord, 0).rgb;
        vec3 currentValue = texelFetch(Sampler0, ivec2(0, sunSize + (1 + cubemapSize.y) * i + 1) + relativePixelCoord, 0).rgb;
        fragColor.rgb = mix(previousValue, currentValue, clamp((currentTime - startTime) / (interpolationEndTime - startTime), 0.0, 1.0));
    }

    if (!found) {
        // We're before the first start time, we should use the last cubemap for this
        fragColor.rgb = texelFetch(Sampler0, ivec2(0, sunSize + (1 + cubemapSize.y) * (cubemapCount - 1) + 1) + relativePixelCoord, 0).rgb;
    }

    // Raytrace the original sun
    vec3 normal = normalize(cross(pos1 - pos2, pos3 - pos2));
    // Ray-Plane intersection
    float t = dot(center, normal) / dot(rayDir, normal);
    if (t > 0.0) {
        vec3 hitPos = rayDir * t;
        vec3 sideX = pos3 - pos2;
        vec3 sideY = pos1 - pos2;
        vec2 uv = vec2(
            dot(hitPos - pos2, sideX) / dot(sideX, sideX),
            dot(hitPos - pos2, sideY) / dot(sideY, sideY)
        );
        if (clamp(uv, 0.0, 1.0) == uv) {
            // Draw the sun
            fragColor.rgb += texelFetch(Sampler0, ivec2(uv * sunSize), 0).rgb;
        }
    }

}
