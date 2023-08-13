#include "/common_defs.glsl"

/* DRAWBUFFERS: */
in vec2 texcoord;

in vec3 normal;
in vec3 position;

#define use_shadow_light_position

#define use_texture

#include "/lib/use.glsl"

void main() {
    #if defined SHADOWS_ENABLED
        // sign of dot product determines sign of epsilon
        vec4 albedo = texture2D(texture, texcoord);
        // throw out transparent stuff
        if(albedo.a < EPSILON) discard;
        // if(dot(viewInverse(shadowLightPosition), normal) > 0.0 || albedo.a < EPSILON) discard;
    #endif
}