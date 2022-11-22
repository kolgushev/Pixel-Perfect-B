#include "/lib/common_defs.glsl"
#if defined gc_terrain || defined gc_textured
    #define use_raw_normal
#endif
#if defined gc_terrain || defined gc_sky
    #define use_raw_position
#endif

out vec2 texcoord;
out vec4 color;
out vec2 light;
out vec3 position;
out vec3 normal;

#if defined g_skybasic
    out vec2 stars;
#endif

in vec2 vaUV0;
in ivec2 vaUV2;
in vec4 vaColor;
in vec3 vaNormal;
in vec3 vaPosition;

#if defined g_terrain
    in vec4 mc_Entity;
#endif

uniform vec3 chunkOffset;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferModelViewInverse;

#include "/lib/to_viewspace.glsl"

#if defined g_terrain
    #include "/lib/get_terrain_mask.glsl"
#endif

void main() {
    #if defined use_raw_position
        position = chunkOffset + vaPosition;
        vec4 glPos = toViewspace(projectionMatrix, modelViewMatrix, position);
    #else
        position = viewInverse(vaPosition);
        vec4 glPos = toViewspace(projectionMatrix, modelViewMatrix, vaPosition);
    #endif
    gl_Position = glPos;

    texcoord = vaUV0;
    color = vaColor;
    light = (LIGHT_MATRIX * vec4(vaUV2, 1, 1)).xy;
    light = max(vec2(light.rg) - 0.0313, 0) * 1.067;
    #if defined use_raw_normal
        normal = vaNormal;

        #if defined g_terrain
            float fakeNormal = (getCutoutMask(mc_Entity.x) - 2) * CUTOUT_ALIGN_STRENGTH;
            normal = mix(normal, vec3(0, sign(fakeNormal), 0), abs(fakeNormal));
        #endif
    #else
        normal = viewInverse(vaNormal);
    #endif

    #if defined g_skybasic
        stars = vec2(color.r, color.r == color.g && color.g == color.b && color.r > 0.0);
    #endif
}