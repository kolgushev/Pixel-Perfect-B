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
flat in int isLit;

#if defined g_skybasic
    in vec2 stars;
#endif

uniform sampler2D texture;
uniform sampler2D shadowcolor0;

uniform float alphaTestRef;

uniform vec4 entityColor;
uniform int isEyeInWater;
uniform float nightVision;

uniform vec3 fogColor;
uniform vec3 skyColor;

uniform int renderStage;


#if defined gc_transparent
    uniform vec3 sunPosition;
    uniform vec3 moonPosition;

    uniform int moonPhase;
    uniform float rainStrength;

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
#endif

#if (defined gc_sky || defined gc_transparent) && defined DIM_END
    uniform int bossBattle;
#endif

#include "/lib/tonemapping.glsl"
#include "/lib/calculate_sky.glsl"
#include "/lib/hdr_mapping.glsl"

#if defined gc_transparent
    #include "/lib/fogify.glsl"
    #include "/lib/color_manipulation.glsl"
    #include "/lib/to_viewspace.glsl"
    #include "/lib/calculate_lighting.glsl"
#endif

#if defined gc_sky
    #include "/lib/switch_fog_color.glsl"
#endif

void main() {
    vec3 lightmap = vec3(light, color.a);

    vec3 customFogColor = mix(fogColor, skyColor, SKY_COLOR_BLEND);

    #if defined g_skybasic
        // TODO: make a proper sunset
        if(renderStage == MC_RENDER_STAGE_SUNSET) discard;

        vec4 albedo = stars.g > 0.5 ? opaque1(stars.r) * NIGHT_SKY_LIGHT_MULT * STAR_WEIGHTS : opaque(calcSkyColor(normalize(position), skyColor, customFogColor));
        /*  The sky is rendered using a cylinder-like shape at the top and a flat shape at the bottom.
            For some reason the vaPosition for the flat shape translates to the same as texcoord when
            mapped to clipspace, so we need to detect that and set it to the fog color
            instead of evaluating the gradient.
        */
        if(distance(color.rgb, fogColor) < EPSILON) albedo = opaque(customFogColor);
    #else
        vec4 albedo = texture2D(texture, texcoord);
        albedo.rgb *= color.rgb;
        // We didn't add this into the color in vsh since color is multiplied and entityColor is mixed
        albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);
    #endif

    // prevent underground sun/moon, add virtual horizon
    #if defined g_skytextured
        albedo.a = smoothstep(-0.05, 0.01, normalize(position).y);
    #endif

    #if defined g_weather
        albedo.a *= 0.5 * rainStrength;
    #endif
    
    if(albedo.a < alphaTestRef) discard;

    albedo.rgb = gammaCorrection(albedo.rgb, GAMMA);

    #if defined g_skybasic
        // saturate
        albedo.rgb = max(vec3(0), saturateRGB(SKY_SATURATION) * albedo.rgb);
    #endif

    albedo.rgb *= RGB_to_ACEScg;

    #if defined g_skytextured
        // since we're using an advanced color pipeline it's safe to pump up the skytextured brightness
        albedo.rgb *= mix(MOON_LIGHT_MULT, SUN_LIGHT_MULT, skyTime(worldTime));
    #endif

    #if defined gc_sky
        #if defined SKY_ADDITIVE
            #if defined DIM_END
                if(bossBattle != 2) {
            #endif
                    albedo.rgb += SKY_ADDITIVE;
            #if defined DIM_END
                }
            #endif
        #endif


        // anything more than about 100 causes an overflow
        albedo.rgb *= clamp(SKY_LIGHT_MULT * 0.45, 0, 100) * SKY_BRIGHTNESS;

        #if defined DIM_END
            if(bossBattle == 2) {
                albedo.rgb *= BOSS_BATTLE_SKY_MULT;
            }
        #endif

        albedo.rgb = getFogColor(isEyeInWater, albedo.rgb);
    #endif

    #if defined HDR_TEX_LIGHT_BRIGHTNESS        
        if(isLit == 1) {
            albedo.rgb = SDRToHDRColor(albedo.rgb);
        }
    #endif

    #if defined gc_transparent
        // apply lighting here for transparent stuff
        mat2x3 lightColor = getLightColor(lightmap, normal, view(normal), sunPosition, moonPosition, moonPhase, worldTime, rainStrength, nightVision, darknessFactor, darknessLightFactor, shadowcolor0);
        
        #if defined SHADOWS_ENABLED
            vec4 directLighting = opaque(lightColor[1]) * albedo;
            albedo.rgb *= lightColor[0];
        #else
            albedo.rgb *= lightColor[0] + lightColor[1] * basicDirectShading(lightmap.g);
        #endif

        // apply fog as well
        vec4 fogged = fogify(position, albedo.rgb, far, isEyeInWater, nightVision, gammaCorrection(fogColor, GAMMA) * RGB_to_ACEScg);

        albedo.rgb = fogged.rgb;
        albedo.a *= 1 - fogged.a;

        // TODO: find out why water lighting is being inherited from opaque geometry
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