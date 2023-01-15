#include "/common_defs.glsl"

/* DRAWBUFFERS:04 */
layout(location = 0) out vec4 b0;
layout(location = 4) out vec4 b4;

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex4;

void main() {
    vec3 previousAntialiased = texture(colortex4, texcoord).rgb;
    vec3 currentFrame = texture(colortex0, texcoord).rgb;


    vec3 newAntialiased = mix(previousAntialiased, currentFrame, 0.25);
    // vec3 newAntialiased = currentFrame;
    b0 = opaque(newAntialiased);
    b4 = opaque(newAntialiased);
}