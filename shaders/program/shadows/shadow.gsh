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

	float range = 256;
	float sqrtNumLayers = 16;

	vec2 startPos = vec2(0);
	startPos.x = int(center.y) % int(sqrtNumLayers);
	startPos.y = floor(center.y / sqrtNumLayers);

	for(int i = 0; i < 3; i++) {
		texcoord = texcoordV[i];
		position = positionV[i];
		normal = normalV[i];

		// position.xz = distance(position.xz, vec2(0)) < range ? position.xz / range : vec2(0);
		position.xz /= range * sqrtNumLayers * 2;

		position.xz += startPos / sqrtNumLayers;

		position.xyz = position.xzy;

		gl_Position = vec4(position.xy, 0.5, 1.0);
		// gl_Position = vec4(position, 1.0);

		EmitVertex();
	}
	EndPrimitive();
}