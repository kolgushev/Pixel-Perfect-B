#include "/common_defs.glsl"

layout(location = 0) out vec4 buffer0;

in vec2 texcoord;


// uniforms

#define use_colortex0

#if defined SHADOW_DEBUG
    #define use_shadowcolor1
    #define use_noisetex

    #define use_get_shadow
#endif

#include "/lib/use.glsl"

void main() {
    vec4 albedo = texture(colortex0, texcoord);
    buffer0 = albedo;

    #if defined SHADOW_DEBUG
        vec2 texcoordMod = supersampleSampleShift(texcoord);
        buffer0 = opaque1(texture(shadowcolor1, texcoordMod).r);
        // buffer0 = opaque(tile(texcoord * 256, vec2(1,0)).rgb);
        // buffer0 = opaque(texture(noisetex, texcoord).rgb);
    #endif
}