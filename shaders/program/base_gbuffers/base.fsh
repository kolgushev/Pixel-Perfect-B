#include "/common_defs.glsl"

/* DRAWBUFFERS:0123 */
layout(location = 0) out vec4 b0;
layout(location = 1) out vec4 b1;
layout(location = 2) out vec3 b2;
layout(location = 3) out vec3 b3;

in vec2 texcoord;
in vec4 color;
in vec2 light;
in vec3 position;
in vec3 normal;
flat in int mcEntity;

#if defined g_skybasic
    in vec2 stars;
#endif

uniform sampler2D texture;
uniform sampler2D shadowcolor0;

uniform vec4 entityColor;
uniform int isEyeInWater;
uniform float nightVision;

uniform vec3 fogColor;
uniform vec3 skyColor;

uniform float isLightning;

uniform int renderStage;


#if defined gc_transparent
    uniform vec3 sunPosition;
    uniform vec3 moonPosition;

    uniform float darknessFactor;
    uniform float darknessLightFactor;

    uniform float far; 
    uniform mat4 gbufferModelView;


    uniform float viewWidth;
    uniform float viewHeight;

    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferModelViewInverse;

    uniform sampler2D colortex0;
    uniform sampler2D depthtex1;
#endif

#if defined gc_transparent || defined g_skytextured || defined g_weather
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
    #include "/lib/to_viewspace.glsl"
#endif

#if defined gc_transparent || defined g_weather || defined g_skybasic
    uniform int moonPhase;
    uniform float rainStrength;

    #include "/lib/color_manipulation.glsl"
    #include "/lib/calculate_lighting.glsl"
#endif

#if defined gc_sky
    #include "/lib/switch_fog_color.glsl"
#endif

#if defined g_terrain || defined gc_transparent
    uniform vec3 cameraPosition;
    uniform float frameTimeCounter;

    uniform sampler2D noisetex;

    #include "/lib/sample_noisetex.glsl"

    #include "/lib/lava_noise.glsl"
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
        #if !defined g_terrain
            albedo.a *= color.a;
        #endif
        #if defined g_basic
            if(renderStage == MC_RENDER_STAGE_OUTLINE) {
                albedo = vec4(0.2, 0.2, 0.2, 0.8);
            }
        #elif defined g_damagedblock
            albedo.a = clamp(albedo.a - 0.003, 0, 1);
        #endif
        
        // We didn't add this into the color in vsh since color is multiplied and entityColor is mixed
        albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);
    #endif

    #if defined g_skytextured
        #if defined DIM_END
            float degree = smoothstep(-1, 0.4, normalize(position).y);
            albedo.rgb *= degree;
        #elif !defined DIM_NO_SKY
            // prevent underground sun/moon, add virtual horizon
            albedo.a = smoothstep(-0.05, 0.01, normalize(position).y);
        #endif
    #endif
    
    if(albedo.a < EPSILON) discard;
    
    albedo.rgb = gammaCorrection(albedo.rgb, GAMMA);

    #if defined g_skybasic
        // saturate
        albedo.rgb = max(vec3(0), saturateRGB(SKY_SATURATION) * albedo.rgb);
    #endif

    albedo.rgb *= RGB_to_ACEScg;

    #if defined DIM_TEST
        albedo.rgb = vec3(1, 0, 0);
    #endif

    #if defined g_skybasic
        albedo.rgb += lightningFlash(isLightning, rainStrength) * 0.1;

        if(isEyeInWater == 1) {
            albedo.rgb = ATMOSPHERIC_FOG_COLOR_WATER;
        }
    #endif

    #if defined g_skytextured
        // since we're using an advanced color pipeline it's safe to pump up the skytextured brightness
        albedo.rgb *= mix(MOON_LIGHT_MULT, SUN_LIGHT_MULT, skyTime(worldTime)) * PLANET_BRIGHTNESS;
    #endif

    #if defined g_weather && !defined DIM_NO_RAIN
        const float a = 1.5;
        float skyTransition = skyTime(worldTime);
        albedo.a *= 0.25 * rainStrength;
        albedo.rgb *= 
            rainMultiplier(rainStrength) * mix(moonBrightness(moonPhase) * MOON_COLOR, SUN_COLOR, skyTransition)
            + actualSkyColor(skyTransition)
            + lightningFlash(isLightning, rainStrength);
        albedo.rgb *= 0.5;
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
        #if !defined gc_emissive
            if(mcEntity == LIT || mcEntity == LIT_CUTOUTS || mcEntity == LIT_CUTOUTS_UPSIDE_DOWN || mcEntity == LAVA || mcEntity == WAVING_CUTOUTS_BOTTOM_LIT) {
        #endif
                albedo.rgb = SDRToHDR(albedo.rgb);
        #if !defined gc_emissive
            }
        #endif
    #endif

    #if defined g_terrain && NOISY_LAVA != 0
        if(mcEntity == LAVA) {
            albedo.rgb *= lavaNoise(position.xz + cameraPosition.xz, frameTimeCounter);
        }
    #endif

    #if defined gc_transparent
        // apply lighting here for transparent stuff
        mat2x3 lightColor = getLightColor(
            lightmap,
            normal,
            view(normal),
            sunPosition,
            moonPosition,
            moonPhase,
            skyTime(worldTime),
            rainStrength,
            nightVision,
            darknessFactor,
            darknessLightFactor,
            isLightning,
            shadowcolor0);
        
        #if defined SHADOWS_ENABLED
            vec4 directLighting = opaque(lightColor[1]) * albedo;
            albedo.rgb *= lightColor[0];
        #else
            albedo.rgb *= lightColor[0] + lightColor[1] * basicDirectShading(lightmap.g);
        #endif

        vec3 positionOpaque = position;
        vec3 diffuse = albedo.rgb;
        #if defined WATER_FOG_FROM_OUTSIDE
            if(mcEntity == WATER) {
                vec2 texcoordScreenspace = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

                float depth = texture2D(depthtex1, texcoordScreenspace).r;
                vec3 diffuse = texture2D(colortex0, texcoordScreenspace).rgb;
                positionOpaque = getWorldSpace(gbufferProjectionInverse, gbufferModelViewInverse, texcoordScreenspace, depth).xyz;
            }
        #endif

        // apply fog as well
        vec4 fogged = fogify(position, positionOpaque, albedo, diffuse, far, isEyeInWater, nightVision, gammaCorrection(fogColor, GAMMA) * RGB_to_ACEScg, cameraPosition, frameTimeCounter, lavaNoise(cameraPosition.xz, frameTimeCounter));

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