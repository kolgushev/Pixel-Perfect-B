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
	float center = 0;

	for(int i = 0; i < 3; i++) {
		center += positionV[i].y;
	}

	const float range = 256;
	const float sqrtNumLayers = 16;

	center *= RCP_3;

	// map from -range/2|+range/2 to 0|range
	center += range * 0.5;

	vec2 startPos = vec2(0);
	// 0|sqrtNumLayers-1
	startPos.x = int(center) % int(sqrtNumLayers);
	// 0|range/sqrtNumLayers
	startPos.y = floor(center / sqrtNumLayers);

	for(int i = 0; i < 3; i++) {
		texcoord = texcoordV[i];
		position = positionV[i];
		normal = normalV[i];

		// map to 0|1
		position.xz /= range;
		position.xz += 0.5;

		// position.xz += startPos;

		// map from 0|sqrtNumLayers to 0|1
		position.xz /= sqrtNumLayers;

		gl_Position = vec4(position.xz, 0.0, 1.0);
		// gl_Position = vec4(position, 1.0);

		EmitVertex();
	}
	EndPrimitive();
}