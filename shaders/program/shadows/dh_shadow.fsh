#define g_fsh
#include "/common_defs.glsl"

/* DRAWBUFFERS:1 */
varying vec2 texcoord;

varying vec3 normal;
varying vec3 position;

#include "/lib/use.glsl"

void main() {
    #if defined SHADOWS_ENABLED
        // sign of dot product determines sign of epsilon
        vec4 albedo = texture(gtexture, texcoord);
        // throw out transparent stuff
        if(albedo.a < EPSILON) discard;
        // if(dot(viewInverse(shadowLightPosition), normal) > 0.0 || albedo.a < EPSILON) discard;

        gl_FragData[0] = vec4(0.0);
    #endif
}