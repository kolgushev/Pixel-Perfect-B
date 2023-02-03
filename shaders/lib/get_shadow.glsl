float getShadow(in vec3 position, in vec3 cameraPosition, in vec3 normal, in mat4 shadowProjection, in mat4 shadowModelView, in vec2 texcoord, in sampler2D shadowtex, in sampler2D noisetex, in float lightmapLight, in int time) {    
    float shadow = 1;
    // align position to grid
    vec3 posNew = position + 0.1 * normal - floor(cameraPosition) + cameraPosition;


    for(int i = 0; i < SHADOW_MAP_RANGE; i++) {
        posNew.y ++;
        if(texture(shadowtex, voxelize(posNew)).r < 1) {
            shadow = 0;
        }
    }
    
    return shadow;
    // return clamp(floor(position.z), 0, 1);
}