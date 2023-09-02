float fogifyDistanceOnly(in vec3 position, in float far, in float blindness, in float farRcp) {
    // Render fog in a cylinder shape
    float fogFlat = length(position.y);
    float fogTube;
    if(blindness == 0) {
        fogTube = length(position.xz);
        #if defined g_clouds
            fogTube *= CLOUD_EXTENSION;
            #if !defined IS_IRIS
                fogTube *= 8.1;
            #endif
        #endif
        // TODO: optimize, add a colored component similar to atmosPhog
        fogFlat = smoothstep(0.875, 1.0, fogFlat * farRcp);
        fogTube = smoothstep(0.875, 1.0, fogTube * farRcp);
        fogTube = clamp(fogTube + fogFlat, 0.0, 1.0);
    } else {
        fogTube = length(position);
        fogTube = mix(fogTube * farRcp * 8 - 7, fogTube * 0.2, blindness);

        fogTube = smoothstep(0.0, 1.0, fogTube);
    }
    

    return fogTube;
}

vec4 fogify(in vec3 position, in vec3 positionWater, in vec4 transparency, in vec3 diffuse, in float far, in int isEyeInWater, in float nightVisionEffect, in float blindnessEffect, in bool isSpectator, in float fogWeather, in vec3 fogColor, in vec3 cameraPosition, in float frameTimeCounter, in float lavaNoise) {
    vec3 composite = diffuse.rgb;
    float farRcp = 1 / far;
    float fogTube = fogifyDistanceOnly(position, far, blindnessEffect, farRcp);

    float atmosPhog = 1.0;
    vec3 atmosPhogColor = vec3(0);
    float nightVisionVisibility = 0;
    if(isEyeInWater == 0) {
        #if defined ATMOSPHERIC_FOG || defined FOG_ENABLED
            float densityWater = RAIN_ADDER;
            float densityTotal = ATMOSPHERIC_FOG_DENSITY * ATMOSPHERIC_FOG_MULTIPLIER + densityWater;

            atmosPhog = length(position) * densityTotal;
            #if defined FOG_ENABLED
                float mult = fogWeather * WEATHER_FOG_MULTIPLIER;
                #if defined ATMOSPHERIC_FOG
                    #if defined ATMOSPHERIC_FOG_IN_SKY_ONLY
                        mult += IN_SKY_PROCESSED;
                    #else
                        mult += 1;
                    #endif
                #endif
                atmosPhog *= mult;
            #elif defined ATMOSPHERIC_FOG_IN_SKY_ONLY
                atmosPhog *= IN_SKY_PROCESSED;
            #endif
            atmosPhogColor = mix(ATMOSPHERIC_FOG_COLOR, ATMOSPHERIC_FOG_COLOR_RAIN, densityWater / densityTotal);
            #if defined DIM_END
                if(bossBattle == 2) {
                    atmosPhogColor = BOSS_BATTLE_ATMOSPHERIC_FOG_COLOR;
                }
            #endif
            atmosPhog = exp(-atmosPhog);
        #endif
    }
    #if defined WATER_FOG
        else if (isEyeInWater != 1) {
            // hijack atmospheric fog calculations for underwater
            switch(isEyeInWater) {
                // water fog will be added in post layer
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

            atmosPhog = length(positionWater) * atmosPhog * (1 - nightVisionEffect * nightVisionVisibility);


            atmosPhog = exp(-atmosPhog);
        }
    #endif

    #if defined SECONDARY_FOG
        float secondaryFog = smoothstep(SECONDARY_FOG_START, SECONDARY_FOG_END, length(position) * farRcp);
        composite = mix(composite, atmosPhogColor * SECONDARY_FOG_COLOR_MULTIPLIER, secondaryFog);
    #endif

    composite = mix(atmosPhogColor, composite, atmosPhog);


    return vec4(composite, fogTube);
}