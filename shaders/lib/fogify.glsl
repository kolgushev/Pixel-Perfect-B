float fogifyDistanceOnly(in vec3 position, in float far, in float blindness) {
    // Render fog in a cylinder shape
    float farRcp = mix(1 / far, 0.05, blindness);
    float fogFlat = length(position.y);
    float fogTube = length(position.xz) + 16;
    
    // TODO: optimize, add a colored component similar to atmosPhog
    fogFlat = pow(clamp((fogFlat * farRcp * 8 - 7), 0, 1), 2);
    fogTube = pow(clamp((fogTube * farRcp * 8 - 7), 0, 1), 2);
    fogTube = clamp(fogTube + fogFlat, 0, 1);

    return fogTube;
}

vec4 fogify(in vec3 position, in vec3 positionOpaque, in vec4 transparency, in vec3 diffuse, in float far, in int isEyeInWater, in float nightVisionEffect, in float blindnessEffect, in bool isSpectator, in float fogWeather, in float inSky, in vec3 fogColor, in vec3 cameraPosition, in float frameTimeCounter, in float lavaNoise) {
    vec3 composite = diffuse.rgb;

    float fogTube = fogifyDistanceOnly(position, far, blindness);

    float atmosPhog = 1.0;
    #if defined WATER_FOG_FROM_OUTSIDE
        float atmosPhogWater = 1.0;
    #endif
    vec3 atmosPhogColor = vec3(0);
    float nightVisionVisibility = 0;
    if(isEyeInWater == 0) {
        #if defined ATMOSPHERIC_FOG || defined FOG_ENABLED
            atmosPhog = length(position) * ATMOSPHERIC_FOG_DENSITY * ATMOSPHERIC_FOG_MULTIPLIER;
            #if defined FOG_ENABLED
                float mult = fogWeather * WEATHER_FOG_MULTIPLIER;
                #if defined ATMOSPHERIC_FOG
                    #if defined ATMOSPHERIC_FOG_IN_SKY_ONLY
                        mult += inSky;
                    #else
                        mult += 1;
                    #endif
                #endif
                atmosPhog *= mult;
            #elif defined ATMOSPHERIC_FOG_IN_SKY_ONLY
                atmosPhog *= inSky;
            #endif
            atmosPhogColor = ATMOSPHERIC_FOG_COLOR;
            #if defined DIM_END
                if(bossBattle == 2) {
                    atmosPhogColor = BOSS_BATTLE_ATMOSPHERIC_FOG_COLOR;
                }
            #endif
            atmosPhog = exp(-atmosPhog);
        #endif

        #if defined WATER_FOG_FROM_OUTSIDE
            atmosPhogWater = distance(position, positionOpaque) * ATMOSPHERIC_FOG_DENSITY_WATER;
            atmosPhogWater = exp(-atmosPhogWater);
        #endif
    } else {
        // hijack atmospheric fog calculations for underwater
        switch(isEyeInWater) {
            case 1:
                atmosPhog = ATMOSPHERIC_FOG_DENSITY_WATER;
                atmosPhogColor = ATMOSPHERIC_FOG_COLOR_WATER;
                nightVisionVisibility = NIGHT_VISION_AFFECTS_FOG_WATER;
                if(isSpectator) {
                    atmosPhog *= ATMOSPHERIC_FOG_SPECTATOR_MULT_WATER;
                }
                break;
            case 2:
                atmosPhog = ATMOSPHERIC_FOG_DENSITY_LAVA;
                atmosPhogColor = ATMOSPHERIC_FOG_COLOR_LAVA * lavaNoise;
                nightVisionVisibility = NIGHT_VISION_AFFECTS_FOG_LAVA;
                if(isSpectator) {
                    atmosPhog *= ATMOSPHERIC_FOG_SPECTATOR_MULT_LAVA;
                }
                break;
            case 3:
                atmosPhog = ATMOSPHERIC_FOG_DENSITY_POWDER_SNOW;
                atmosPhogColor = ATMOSPHERIC_FOG_COLOR_POWDER_SNOW;
                nightVisionVisibility = NIGHT_VISION_AFFECTS_FOG_POWDER_SNOW;
                if(isSpectator) {
                    atmosPhog *= ATMOSPHERIC_FOG_SPECTATOR_MULT_POWDER_SNOW;
                }
                break;
        }

        atmosPhog = length(position) * atmosPhog * (1 - nightVisionEffect * nightVisionVisibility);


        atmosPhog = exp(-atmosPhog);
    }

    #if defined WATER_FOG_FROM_OUTSIDE
        // The following math attempts to compensate for the fact that we're doing water fog in gc_transparent instead of g_terrain
        // aka. we're doing `mix(composite, mix(fog, transparent))` instead of `mix(mix(fog, composite), transparent)` and compensating for it by specially coloring the transparent layer

        // wolfram|alpha -> solve g(g(b,a,c),d,f)=g(a,x,f) for x where g(m,n,o)=m*(o-1)+n*o ->
        // x = ((a + b) * (c - 1) * (f - 1) + d * f) / f and f!=0
        // for: a=composite, b=ATMOSPHERIC_FOG_COLOR_WATER, c=atmosPhogWater, d=transparency.rgb, f=transparency.a
        if(position != positionOpaque && isEyeInWater == 0) {
            composite = ((composite + ATMOSPHERIC_FOG_COLOR_WATER) * (atmosPhogWater - 1) * (transparency.a - 1) + transparency.rgb * transparency.a) / transparency.a;
        }
    #endif

    composite = mix(atmosPhogColor, composite, atmosPhog);

    return vec4(composite, fogTube);
}