#include "/common_defs.glsl"

layout(location = 1) out float b1;

in vec2 texcoord;

uniform sampler2D shadowtex1;

uniform int frameCounter;

#include "/lib/distortion.glsl"

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