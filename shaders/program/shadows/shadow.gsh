#include "/common_defs.glsl"

layout (triangles) in;
layout (triangle_strip, max_vertices = 6) out;

in vec2 texcoordV[];
in vec3 positionV[];
in vec3 normalV[];

out vec2 texcoord;
out vec3 position;
out vec3 normal;

#include "/lib/voxelize.glsl"

void main() {
	vec3 center = vec3(0);

	for(int i = 0; i < 3; i++) {
		center += positionV[i];
	}

	center *= RCP_3;

	// map from -range/2|+range/2 to 0|range
	center += SHADOW_MAP_RANGE * 0.5;

	vec2 startPos = flatten(center);

	const vec2 offsets[3] = vec2[3](
		vec2(0, 0),
		vec2(1, 0),
		vec2(0.5, 1)
	);

	for(int i = 0; i < 3; i++) {
		texcoord = texcoordV[i];
		normal = normalV[i];
		position = positionV[i];

		// turn all positions into "perfect" triangles
		vec2 pos2D = startPos + offsets[i];

		// map to 0|1
		pos2D /= SHADOW_MAP_RANGE * SHADOW_MAP_SQRT_NUM_LAYERS;

		gl_Position = vec4(pos2D * 2 - 1, 0.0, 1.0);

		EmitVertex();
	}
	EndPrimitive();
}