#include "/lib/common_defs.glsl"

#if AO_MODE == 1
    const float ambientOcclusionLevel = 1.0;
#else
   const float ambientOcclusionLevel = 0;
#endif

layout(location = 0) out vec4 buffer0;
layout(location = 1) out vec4 buffer1;
layout(location = 2) out vec4 buffer2;
layout(location = 3) out vec4 buffer3;
layout(location = 4) out vec4 buffer4;
layout(location = 5) out vec4 buffer5;
layout(location = 6) out vec4 buffer6;

in vec2 texcoord;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

uniform float far;
uniform mat4 gbufferProjectionInverse;
uniform float alphaTestRef;
uniform sampler2D texture;

in float currentSkyWhitePoint;

in vec3 position;
in vec4 light;
in vec4 color;
in vec3 normal;
in vec4 masks;
in vec3 velocity;

#if defined g_skybasic
    in vec4 stars;

    uniform vec3 fogColor;
    uniform vec3 skyColor;

    uniform mat4 gbufferModelView;
#endif

#include "/lib/tonemapping.glsl"
#include "/lib/to_viewspace.glsl"

void main() {
    #if defined g_skybasic
        // TODO: fix
        vec3 skyColorProcessed = stars.a > 0.5 ? stars.rgb : skyColor;
        #ifdef GAMMA_CORRECT_PRE
            // linearize albedo
            skyColorProcessed = gammaCorrection(skyColorProcessed, GAMMA);
        #endif
        skyColorProcessed = skyColorProcessed * RGB_to_ACEScg;
        // vec3 skyColor = stars.a > 0.5 ? stars.rgb : calcSkyColor(normalize(projectInverse(vec3(position.xy / vec2(viewWidth, viewHeight) * 2 - 1, 1))));
    #endif

    // MASKS: r-ignores shading g-terrain b-emissive

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

    albedo *= opaque(masks.r > 0.5 ? color.rgb : color.rgb * light.rgb);
    // albedo *= opaque(color.rgb);
    // albedo = opaque1(light.a);

    #if defined g_skybasic
        buffer0 = opaque(skyColor);
    #else
        buffer0 = albedo;
    #endif
    buffer1 = opaque(normal);
    buffer2 = opaque(position);
    buffer3 = vec4(light.w, velocity.xyz);
    buffer4 = masks;
}