float getShadow(in vec3 position, in vec3 cameraPosition, in vec3 normal, in mat4 shadowProjection, in mat4 shadowModelView, in vec2 texcoord, in sampler2D shadowtex, in sampler2D noisetex, in float lightmapLight, in int time) {    

    float skyTransition = abs(fma(skyTime(time), 2, -1));
    float dist = length(position);
    float shadowCutoff = clamp(fma(dist / (shadowDistance * SHADOW_CUTOFF), 10, -9), 0, 1);
    float shadowMask = skyTransition * (1 - shadowCutoff);

    float shadow = 1;
    // align position to grid
    vec3 posNew = position + 0.02 * normal - ceil(cameraPosition) + cameraPosition;


    for(int i = 0; i < SHADOW_MAP_RANGE; i++) {
        if(texture(shadowtex, voxelize(posNew)).r < 1) {
            shadow = 0;
            break;
        }
        posNew.y ++;
    }
    
    shadow = mix(shadow, 1, shadowCutoff);
    shadow = mix(SHADOW_TRANSITION_MIXING, shadow, skyTransition);
    
    #if defined SHADOW_AFFECTED_BY_LIGHTMAP
        shadow *= lightmapLight;
    #endif

    return shadow;
    // return clamp(floor(position.z), 0, 1);
}