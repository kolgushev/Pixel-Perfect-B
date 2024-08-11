#define g_fsh
#include "/common_defs.glsl"

/* DRAWBUFFERS: */
varying vec2 texcoord;

varying vec3 normal;
varying vec3 position;

#include "/lib/use.glsl"

void main() {
    #if defined SHADOWS_ENABLED && defined DH_SHADOWS_ENABLED
        // sign of dot product determines sign of epsilon
        vec4 albedo = texture(gtexture, texcoord);
        // throw out transparent stuff
        if(albedo.a < EPSILON) discard;
        // if(dot(viewInverse(shadowLightPosition), normal) > 0.0 || albedo.a < EPSILON) discard;
    #endif
}