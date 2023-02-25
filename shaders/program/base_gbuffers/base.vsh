#include "/common_defs.glsl"
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
uniform float frameTimeCounter;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferModelViewInverse;

uniform int renderStage;


#include "/lib/to_viewspace.glsl"

#if defined g_terrain
    #if defined WAVING_ENABLED
        uniform sampler2D noisetex;
        uniform vec3 cameraPosition;
        // uniform float frameTimeCounter;

        #include "/lib/sample_noisetex.glsl"
    #endif

    #include "/lib/get_terrain_mask.glsl"
#endif

void main() {

    texcoord = vaUV0;
    
    color = vaColor;

    light = (LIGHT_MATRIX * vec4(vaUV2, 1, 1)).xy;
    /*
    The Optifine-provided lightmap is actually used to sample the
    vanilla lighting texture, so it isn't in a 0-1 range by default.
    */
    #if VANILLA_LIGHTING == 2
        light = max(light - 0.0313, 0) * 1.067;
    #endif

    #if defined use_raw_normal
        normal = vaNormal;

        #if defined g_terrain
            float fakeNormal = (getCutoutMask(mc_Entity.x) - 2) * CUTOUT_ALIGN_STRENGTH;
            normal = mix(normal, vec3(0, sign(fakeNormal), 0), abs(fakeNormal));
        #endif
    #else
        normal = viewInverse(vaNormal);
    #endif

    #if defined use_raw_position
        position = chunkOffset + vaPosition;
    #else
        position = viewInverse(vaPosition);
    #endif

    #if defined g_terrain && defined WAVING_ENABLED
        position += (tile((position.xz + cameraPosition.xz) * 1 + 40 * (frameTimeCounter * NOISETEX_TILES_WIDTH * NOISETEX_TILES_RES / 3600), vec2(1,0)).rgb - 0.5) * vec3(2, 0.1, 2);
    #endif

    #if defined use_raw_position
        vec4 glPos = toForcedViewspace(projectionMatrix, modelViewMatrix, position, frameTimeCounter);
    #else
        vec4 glPos = toForcedViewspace(projectionMatrix, modelViewMatrix, vaPosition, frameTimeCounter);
    #endif
    gl_Position = glPos;

    #if defined g_skybasic
        stars = vec2(color.r, color.r == color.g && color.g == color.b && color.r > 0.0);
    #endif
}