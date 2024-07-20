#include "/common_defs.glsl"

in vec3 vaPosition;
in vec2 vaUV0;

out vec2 texcoord;

#include "/lib/use.glsl"

void main() {
	// transform vertices
	vec4 position = vec4(vaPosition * 2 - 1, 1);


	gl_Position = position;
	gl_Position.xy = supersampleShift(gl_Position.xy, frameCounter);
	
	// texcoord = vaUV0;
	texcoord = gl_Position.xy * 0.5 + 0.5;
}