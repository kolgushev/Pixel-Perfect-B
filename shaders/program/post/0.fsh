#include "/common_defs.glsl"

/* DRAWBUFFERS:01 */
layout(location = 0) out vec4 b0;
#if defined FAST_GI || defined DYNAMIC_EXPOSURE_LIGHTING
    layout(location = 1) out vec4 b1;
#endif

in vec2 texcoord;


// uniforms


#define use_colortex0

#include "/lib/use.glsl"

void main() {
    vec3 final = texture(colortex0, texcoord).rgb;

    #if defined FAST_GI || defined DYNAMIC_EXPOSURE_LIGHTING
        b1 = opaque(final);
    #endif

    #if defined DEBUG_VIEW
        b0 = opaque(diffuse);
    #else
        b0 = opaque(final);
    #endif
}