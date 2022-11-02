// set albedo color, multiply by biome color (for grass, leaves, etc.)
vec4 albedo = texture(texture, texcoord);
vec3 albedoProcessed = albedo.rgb;
#ifdef GAMMA_CORRECT_PRE
    albedoProcessed = gammaCorrection(albedo.rgb, GAMMA);
#endif
albedo.rgb = albedoProcessed * RGB_to_ACEScg;
// some layers disable alpha blending (mainly gbuffers_terrain), so we have to process cutouts here
// it also provides a miniscule performance improvement since we don't have to calculate and apply lightmap
if(albedo.a < alphaTestRef) discard;

albedo *= color;

diffuseBuffer = albedo;
normalBuffer = opaque(normal);
// if(albedo.a >= 1 - EPSILON) genericBuffer = opaque(position);
genericBuffer = opaque(position);

// use coordbuffer instead of one of the generics since we don't want to clear them
float depthSpherical = length(position) / far;
coordBuffer = masks.r > 0.5 ? vec4(0, 0, 0, 0) : vec4(0, 1, velocity.xy);
lightmapBuffer = vec4(light, velocity.z);

#ifndef transparent
    maskBuffer = vec4(masks);
#else
    coordBuffer.gba = masks.gba;
#endif