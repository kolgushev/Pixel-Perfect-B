#include "/common_defs.glsl"

layout (triangles) in;
layout (triangle_strip, max_vertices = 6) out;

in vec3 positionp[];

void main() {
	#if defined SHADOWS_ENABLED
		for(int i = 0; i < 6; i++) {
			vec3 pos = gl_in[0].gl_Position.xyz;


			float range = 10;
			float sqrtNumLayers = 10;
			// position.xz = distance(position.xz, vec2(0)) < range ? position.xz / range : vec2(0);
			position.xz = position.xz / range;
			position.xz /= sqrtNumLayers;

			vec2 startPos = vec2(0);
			startPos.x = int(position.y) % int(sqrtNumLayers);
			startPos.y = floor(position.y / sqrtNumLayers);

			position.xz += startPos;

			position.xyz = position.xzy;

			gl_Position = vec4(position, 1.0);
		}
    #else
        gl_Position = vec4(0);
    #endif
}