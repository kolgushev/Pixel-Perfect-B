#include "/lib/common_defs.glsl"

layout(location = 4) out vec4 buffer0;

uniform float far;
uniform mat4 gbufferProjectionInverse;
uniform float alphaTestRef;

#include "/program/base/samplers.fsh"
uniform sampler2D texture;

in float currentSkyWhitePoint;

in vec3 position;
in vec4 light;
in vec4 color;
in vec3 normal;
in vec4 masks;
in vec3 velocity;

#include "/lib/tonemapping.glsl"
#include "/lib/to_viewspace.glsl"

void main() {
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

    buffer0 = vec4(0,0,0,1);
}