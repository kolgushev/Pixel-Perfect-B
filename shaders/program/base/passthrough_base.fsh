vec4 coord = texture(colortex3, texcoord);
float renderable = coord.b;
float texelSurfaceArea = coord.a;
vec2 texcoordMod = texcoord;
#if defined ALIGN && defined TEX_RENDER
if(renderable == 0 || renderable == 1) {
    texcoordMod = coord.rg;
}
#endif
#ifdef SPREAD
    texcoordMod = coord.rg;
#endif

// if(((renderable == 0 || renderable == 1) && align && TEX_RENDER == 1) || spread) {
//     texcoordMod = coord.rg;
// }
#ifdef READ_DEPTH
    float depth = texture(depthtex0, texcoord).r;
#endif

#if (defined READ_ALBEDO && defined WRITE_ALBEDO) || defined OVERRIDE_ALBEDO
    vec4 albedo = texture(colortex0, texcoordMod);
#elif defined READ_ALBEDO
    readonly vec4 albedo = texture(colortex0, texcoordMod);
#elif defined WRITE_ALBEDO
    writeonly vec4 albedo = texture(colortex0, texcoordMod);
#endif
#if (defined READ_NORMAL && defined WRITE_NORMAL) || defined OVERRIDE_NORMAL
    vec3 normal = texture(colortex1, texcoordMod).rgb;
#elif defined READ_NORMAL
    readonly vec3 normal = texture(colortex1, texcoordMod).rgb;
#elif defined WRITE_NORMAL
    writeonly vec3 normal = texture(colortex1, texcoordMod).rgb;
#endif
#if (defined READ_LIGHTMAP && defined WRITE_LIGHTMAP) || defined OVERRIDE_LIGHTMAP
    vec4 lightmap = texture(colortex2, texcoordMod);
#elif defined READ_LIGHTMAP
    readonly vec4 lightmap = texture(colortex2, texcoordMod);
#elif defined WRITE_LIGHTMAP
    writeonly vec4 lightmap = texture(colortex2, texcoordMod);
#endif
#if (defined READ_MASKS && defined WRITE_MASKS) || defined OVERRIDE_MASKS
    vec4 masks = vec4(texture(colortex4, texcoordMod));
#elif defined READ_MASKS
    readonly vec4 masks = vec4(texture(colortex4, texcoordMod));
#elif defined WRITE_MASKS
    writeonly vec4 masks = vec4(texture(colortex4, texcoordMod));
#endif
#if (defined READ_GENERIC && defined WRITE_GENERIC) || defined OVERRIDE_GENERIC
    vec4 generic = texture(colortex5, texcoordMod);
#elif defined READ_GENERIC
    readonly vec4 generic = texture(colortex5, texcoordMod);
#elif defined WRITE_GENERIC
    writeonly vec4 generic = texture(colortex5, texcoordMod);
#endif
#if (defined READ_GENERIC2 && defined WRITE_GENERIC2) || defined OVERRIDE_GENERIC2
    vec4 generic2 = texture(colortex6, texcoordMod);
#elif defined READ_GENERIC2
    readonly vec4 generic2 = texture(colortex6, texcoordMod);
#elif defined WRITE_GENERIC2
    writeonly vec4 generic2 = texture(colortex6, texcoordMod);
#endif
#if (defined READ_GENERIC3 && defined WRITE_GENERIC3) || defined OVERRIDE_GENERIC3
    vec4 generic3 = texture(colortex7, texcoordMod);
#elif defined READ_GENERIC3
    readonly vec4 generic3 = texture(colortex7, texcoordMod);
#elif defined WRITE_GENERIC3
    writeonly vec4 generic3 = texture(colortex7, texcoordMod);
#endif