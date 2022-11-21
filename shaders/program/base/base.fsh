#include "/lib/common_defs.glsl"

layout(location = 1) out vec4 b1;
layout(location = 3) out vec3 b3;
layout(location = 4) out vec3 b4;
layout(location = 5) out vec3 b5;
#if defined gc_sky
    layout(location = 0) out vec4 b0;
#endif
#if defined gc_sky || defined gc_transparent
    layout(location = 2) out vec4 b2;
#endif

in vec2 texcoord;
in vec4 color;
in vec2 light;
in vec3 position;
in vec3 normal;

uniform sampler2D texture;

uniform float alphaTestRef;

#if defined g_skybasic
    uniform mat4 gbufferModelView;
    uniform mat4 gbufferProjectionInverse;
    uniform int viewWidth;
    uniform int viewHeight;

    uniform vec3 skyColor;
    uniform vec3 fogColor;
#endif

#include "/lib/tonemapping.glsl"
#include "/lib/calculate_sky.glsl"

void main() {
    #if defined g_skybasic
        #define skyPosition normalize(position)
        vec4 albedo = opaque(calcSkyColor(skyPosition, skyColor, fogColor));
        /*  The sky is rendered using a dome shape at the top and a flat shape at the bottom.
            For some reason the vaPosition for the flat shape translates to the same as texcoord when mapped to clipspace, so
            we need to detect that and set it to the fog color instead of evaluating the gradient.
        */
        if(distance(color.rgb, fogColor) < EPSILON) albedo = color;
    #else
        vec4 albedo = texture2D(texture, texcoord);
        albedo.rgb *= color.rgb;
    #endif
    if(albedo.a < alphaTestRef) discard;

    albedo.rgb = gammaCorrection(albedo.rgb, GAMMA) * RGB_to_ACEScg;

    #if defined gc_sky
        // ?Even though the sky texture doesn't have an alpha layer, we use alpha in the gbuffers
        // ?for proper mixing of g_skytextured
        b0 = albedo;
        b1 = vec4(0, 0, 0, 0);
        b2 = vec4(0, 0, 0, 0);
    #elif defined gc_transparent
        b2 = albedo;
    #else
        b1 = albedo;
    #endif

    #if !defined gc_transparent
        b3 = vec3(light, color.a);
        b4 = normal;
        b5 = position;
    #endif
}