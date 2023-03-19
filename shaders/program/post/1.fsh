#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 b0;

in vec2 texcoord;

uniform sampler2D colortex0;

uniform int isEyeInWater;

void main() {
	vec3 diffuse = texture(colortex0, texcoord).rgb;

    if(isEyeInWater == 1) {
        diffuse *= OVERLAY_COLOR_WATER;
    }

	b0 = opaque(diffuse);
}