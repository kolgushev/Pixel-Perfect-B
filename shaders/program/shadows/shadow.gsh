#include "/common_defs.glsl"

layout (triangles) in;
layout (triangle_strip, max_vertices = 6) out;

in vec2 texcoordV[];
in vec3 positionV[];
in vec3 normalV[];

out vec2 texcoord;
out vec3 position;
out vec3 normal;


void main() {
	vec3 center = vec3(0);

	for(int i = 0; i < 3; i++) {
		center += positionV[i];
	}

	center *= RCP_3;

	const float range = 256;
	const float sqrtNumLayers = 16;

	// map from -range/2|+range/2 to 0|range
	center += range * 0.5;

	vec2 startPos = vec2(0);
	// 0|sqrtNumLayers-1
	startPos.x = int(center.y) % int(sqrtNumLayers);
	// 0|range/sqrtNumLayers
	startPos.y = floor(center.y / sqrtNumLayers);

	const vec2 offsets[3] = vec2[3](
		vec2(0, 0),
		vec2(1, 0),
		vec2(0.5, 1)
	);

	for(int i = 0; i < 3; i++) {
		texcoord = texcoordV[i];
		normal = normalV[i];

		// turn all positions into "perfect" triangles
		vec2 position = floor(center.xz) + offsets[i];

		// map to 0|1
		position /= range;
		// position.xz += 0.5;

		position += startPos;

		// map from 0|sqrtNumLayers to 0|1
		position /= sqrtNumLayers;
		// position -= 0.5;

		gl_Position = vec4(position * 2 - 1, 0.0, 1.0);

		EmitVertex();
	}
	EndPrimitive();
}