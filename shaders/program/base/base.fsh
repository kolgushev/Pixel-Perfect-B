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

#if defined gc_transparent
    uniform vec3 sunPosition;
    uniform vec3 moonPosition;

    uniform int worldTime;
    uniform int moonPhase;
    uniform float rainStrength;

    uniform float far; 
#endif

#if defined gc_transparent || defined g_skybasic
    uniform mat4 gbufferModelView;
#endif

#if defined g_skybasic
    uniform mat4 gbufferProjectionInverse;
    uniform int viewWidth;
    uniform int viewHeight;

    uniform vec3 skyColor;
    uniform vec3 fogColor;
#endif

#include "/lib/tonemapping.glsl"
#include "/lib/calculate_sky.glsl"
#include "/lib/fogify.glsl"

#if defined gc_transparent
    #include "/lib/calculate_lighting.glsl"
#endif

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

    vec3 lightmap = vec3(light, color.a);
    #if defined gc_transparent
        // apply lighting here for transparent stuff
        vec3 lightColor = getLightColor(lightmap, normal, view(normal), sunPosition, moonPosition, moonPhase, worldTime, rainStrength);
        
        albedo.rgb *= lightColor;

        // apply fog as well
        #define FOGIFY_ALPHA
        vec4 fogged = fogify(position, albedo.rgb, far);

        albedo.rgb = fogged.rgb;
        albedo.a *= 1 - fogged.a;
    #endif

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
        b3 = lightmap;
        b4 = normal;
        b5 = position;
    #endif
}