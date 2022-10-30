// set albedo color, multiply by biome color (for grass, leaves, etc.)
vec4 albedo = texture(texture, texcoord);
albedo.rgb = albedo.rgb * sRGB_to_ACEScg;
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

maskBuffer = vec4(masks);