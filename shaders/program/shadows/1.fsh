#include "/common_defs.glsl"

/* DRAWBUFFERS:1 */
layout(location = 1) out float b1;

in vec2 texcoord;

#define use_shadowtex1
#define use_frame_counter

#define use_distortion

#include "/lib/use.glsl"

void main() {
	float depth = texture(shadowtex1, texcoord).r;
	
	/*
	The culling results in out-of-frustum shadows being cleared normally,
	and when the player turns back it might take up to 16 frames to
	regain those shadows.

	By not clearing culled spaces, the shadows there are kept and the
	outcome usually looks better despite the shadow data being a bit outdated.

	TODO: account for movement of player
	*/
	if(depth == 1.0) discard;
	b1 = depth;
}