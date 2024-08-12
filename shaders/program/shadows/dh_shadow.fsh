
#define g_fsh
#include "/common_defs.glsl"

/* DRAWBUFFERS:0 */
varying vec3 position;

#include "/lib/use.glsl"

void main() {
    #if defined SHADOWS_ENABLED && defined DH_SHADOWS_ENABLED
        // avoid overlapping with standard shadows
        if(gl_FragCoord.x > (0.5 - 0.5 * ISQRT_2) * shadowMapResolution || gl_FragCoord.y > (0.5 - 0.5 * ISQRT_2) * shadowMapResolution) discard;
        
        gl_FragData[0] = vec4(gl_FragCoord.xy / shadowMapResolution, 0.0, 1.0);
    #endif
}