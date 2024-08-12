#define g_fsh
#include "/common_defs.glsl"

/* DRAWBUFFERS: */
in vec2 texcoord;

in vec3 normal;
in vec3 position;
in float dist;

#include "/lib/use.glsl"

void main() {
    #if defined SHADOWS_ENABLED
        // sign of dot product determines sign of epsilon
        vec4 albedo = texture(gtexture, texcoord);
        // throw out transparent stuff
        if(albedo.a < EPSILON || dist > shadowDistance) discard;
        // if(dot(viewInverse(shadowLightPosition), normal) > 0.0 || albedo.a < EPSILON) discard;
    #endif
}