// set albedo color, multiply by biome color (for grass, leaves, etc.)
vec4 albedo = texture2D(texture, texcoord);
vec3 albedoProcessed = albedo.rgb;
#ifdef GAMMA_CORRECT_PRE
    albedoProcessed = gammaCorrection(albedo.rgb, GAMMA);
#endif
albedo.rgb = albedoProcessed * RGB_to_ACEScg;
// some layers disable alpha blending (mainly gbuffers_terrain), so we have to process cutouts here
// it also provides a miniscule performance improvement since we don't have to calculate and apply lightmap
if(albedo.a < alphaTestRef) discard;

// albedo *= opaque(color.rgb * light);
albedo *= opaque(color.rgb);

buffer0 = albedo;
// diffuseBuffer = vec4(light / 16, 0.1);
// we can reconstruct the third normal channel from the other two and a sign
buffer1 = vec4(normal.xyz, 1);
// if(albedo.a >= 1 - EPSILON) genericBuffer = opaque(position);
buffer5 = vec4(position, 1);

// use coordbuffer instead of one of the generics since we don't want to clear them
buffer3 = masks.r > 0.5 ? vec4(0, 0, 0, 0) : vec4(0, velocity.xyz);
// lightmapBuffer = vec4(light, fma(albedo.a, 0.25, 0.3));
buffer2 = vec4(light, albedo.a * fma(dot(albedo.rgb, vec3(SQRT_3)), 0.5, 0.5));

buffer4 = vec4(masks);