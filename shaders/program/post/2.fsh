// Combine passes

#define composite_pass

#include "/lib/common_defs.glsl"

layout(location = 0) out vec4 buffer0;

uniform int worldTime;

in vec2 texcoord;
uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex4;
uniform sampler2D colortex6;
uniform sampler2D colortex7;

#include "/lib/tonemapping.glsl"

void main() {
    vec4 albedo = texture(colortex0, texcoord);
    vec4 lightmap = texture(colortex2, texcoord);
    vec4 masks = vec4(texture(colortex4, texcoord));
    vec4 generic2 = texture(colortex6, texcoord);
    vec4 generic3 = texture(colortex7, texcoord);

    vec3 diffuseOpaque = albedo.rgb;

	if(masks.r < 0.5) {
        #ifdef SSAO_ENABLED
            float ambientOcclusion = 1 - clamp(generic2.b * AO_INTENSITY, 0, 1);
            #ifdef PRETTY_AO
                ambientOcclusion = sqrt(ambientOcclusion);
            #endif
        #else
            float ambientOcclusion = 1;
        #endif

        vec3 lighting = lightmap.rgb;

        vec3 bounceLighting = generic3.rgb;

        // for physical lighting
        // diffuseOpaque *= lighting * ambientOcclusion;
    } else {
        diffuseOpaque = sky(diffuseOpaque, worldTime);
    }

    #if defined USE_NIGHT_EFFECT && !defined NIGHT_EFFECT_AFTER_EXPOSURE
        // apply things-look-blue-at-night-effect
        vec3 darkLightFilter = saturateRGB(NIGHT_EFFECT_SATURATION) * (NIGHT_EFFECT_HUE * diffuseOpaque);

        diffuseOpaque = mix(darkLightFilter, diffuseOpaque, clamp(nightEffect(NIGHT_EFFECT_POINT, luminance(diffuseOpaque)), 0, 1));
    #endif

    #ifndef DEBUG_VIEW
        albedo = opaque(diffuseOpaque);
    #endif

        // albedo = opaque(diffuse / 10000);
        // albedo = opaque(bounceLighting / 1000);
        // albedo = opaque1(ambientOcclusion);
        // albedo = opaque(lightmap.rgb / 10);
    buffer0 = albedo;
    // buffer0 = masks;
}