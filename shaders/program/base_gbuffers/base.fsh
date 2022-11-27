#include "/common_defs.glsl"

#if defined gc_sky || defined gc_transparent
    /* DRAWBUFFERS:0123 */
    layout(location = 0) out vec4 b0;
#else
    /* DRAWBUFFERS:123 */
#endif
layout(location = 1) out vec4 b1;
layout(location = 2) out vec3 b2;
layout(location = 3) out vec3 b3;

in vec2 texcoord;
in vec4 color;
in vec2 light;
in vec3 position;
in vec3 normal;

#if defined g_skybasic
    in vec2 stars;
#endif

uniform sampler2D texture;

uniform sampler2D shadowcolor0;

uniform float alphaTestRef;

uniform vec4 entityColor;


#if defined gc_transparent
    uniform vec3 sunPosition;
    uniform vec3 moonPosition;

    uniform int moonPhase;
    uniform float rainStrength;

    uniform float nightVision;
    uniform float darknessFactor;
    uniform float darknessLightFactor;

    uniform float far; 
    uniform mat4 gbufferModelView;
#endif

#if defined gc_transparent || defined g_skytextured
    uniform int worldTime;
#endif

#if defined g_skybasic
    uniform mat4 gbufferProjectionInverse;
    uniform int viewWidth;
    uniform int viewHeight;

    uniform vec3 skyColor;
    uniform vec3 fogColor;

    uniform int renderStage;
#endif

#include "/lib/tonemapping.glsl"
#include "/lib/calculate_sky.glsl"
#include "/lib/fogify.glsl"

#if defined gc_transparent
    #include "/lib/color_manipulation.glsl"
    #include "/lib/to_viewspace.glsl"
    #include "/lib/calculate_lighting.glsl"
#endif

void main() {
    #if defined g_skybasic
        // TODO: make a proper sunset
        if(renderStage == MC_RENDER_STAGE_SUNSET) discard;

        vec3 customFogColor = mix(fogColor, skyColor, SKY_COLOR_BLEND);

        vec4 albedo = stars.g > 0.5 ? opaque1(stars.r) * NIGHT_SKY_LIGHT_MULT * STAR_WEIGHTS : opaque(calcSkyColor(normalize(position), skyColor, customFogColor));
        /*  The sky is rendered using a dome shape at the top and a flat shape at the bottom.
            For some reason the vaPosition for the flat shape translates to the same as texcoord when mapped to clipspace, so
            we need to detect that and set it to the fog color instead of evaluating the gradient.
        */
        if(distance(color.rgb, fogColor) < EPSILON) albedo = opaque(customFogColor);

        // anything more than about 100 causes an overflow
        albedo *= clamp(SKY_LIGHT_MULT_OVERCAST * 0.9, 0, 100);
    #else
        vec4 albedo = texture2D(texture, texcoord);
        albedo.rgb *= color.rgb;
        // We didn't add this into the color in vsh since color is multiplied and entityColor is mixed
        albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);
    #endif
    if(albedo.a < alphaTestRef) discard;

    albedo.rgb = gammaCorrection(albedo.rgb, GAMMA) * RGB_to_ACEScg;

    #if defined g_skytextured
        // since we're using an advanced color pipeline it's safe to pump up the skytextured brightness
        albedo.rgb *= mix(MOON_LIGHT_MULT, SUN_LIGHT_MULT, skyTime(worldTime));
    #endif

    vec3 lightmap = vec3(light, color.a);
    #if defined gc_transparent
        // apply lighting here for transparent stuff
        mat2x3 lightColor = getLightColor(lightmap, normal, view(normal), sunPosition, moonPosition, moonPhase, worldTime, rainStrength, nightVision, darknessFactor, darknessLightFactor, shadowcolor0);
        
        #if defined SHADOWS_ENABLED
            vec4 directLighting = opaque(lightColor[1]) * albedo;
            albedo.rgb *= lightColor[0];
        #else
            albedo.rgb *= lightColor[0] + lightColor[1] * lightmap.g;
        #endif

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
    #elif defined gc_transparent
        b0 = albedo;
        #if defined SHADOWS_ENABLED
            b1 = directLighting;
        #endif
    #else
        b1 = albedo;
    #endif

    // Even though they should be, these buffers aren't being written to
    // after the deferred phase. What the heck, Optifine?
    b2 = lightmap;
    b3 = normal;
}