#ifdef WRITE_NORMAL
normalBuffer = normal;
#endif
#ifdef WRITE_LIGHTMAP
lightmapBuffer = lightmap;
#endif
#ifdef WRITE_MASKS
maskBuffer = masks;
#endif
#ifdef WRITE_COORD
coordBuffer = vec4(texcoordMod, renderable, texelSurfaceArea);
#endif
#ifdef WRITE_ALBEDO
diffuseBuffer = albedo;
#endif
#ifdef WRITE_GENERIC
genericBuffer = generic;
#endif
#ifdef WRITE_GENERIC2
generic2Buffer = generic2;
#endif
#ifdef WRITE_GENERIC3
generic3Buffer = generic3;
#endif