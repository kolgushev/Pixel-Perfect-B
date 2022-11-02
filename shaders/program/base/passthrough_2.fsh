#ifdef WRITE_NORMAL
buffer1 = normal;
#endif
#ifdef WRITE_LIGHTMAP
buffer2 = lightmap;
#endif
#ifdef WRITE_MASKS
buffer4 = masks;
#endif
#ifdef WRITE_COORD
buffer3 = vec4(texcoordMod, renderable, texelSurfaceArea);
#endif
#ifdef WRITE_ALBEDO
buffer0 = albedo;
#endif
#ifdef WRITE_GENERIC
buffer5 = generic;
#endif
#ifdef WRITE_GENERIC2
buffer6 = generic2;
#endif
#ifdef WRITE_GENERIC3
buffer7 = generic3;
#endif