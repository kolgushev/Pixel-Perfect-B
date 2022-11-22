#include "/lib/common_defs.glsl"

in vec2 texcoord;

uniform sampler2D colortex1;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;

uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform vec3 cameraPosition;

uniform int worldTime;
uniform int moonPhase;
uniform float rainStrength;

uniform mat4 gbufferModelView;

#if defined ENABLE_SHADOWS
    uniform sampler2D shadowtex0;
    uniform mat4 shadowProjection;
    uniform mat4 shadowModelView;
#endif

layout(location = 1) out vec4 b1;

// don't need to include to_viewspace since calculate_lighting already includes it
#include "/lib/calculate_lighting.glsl"
#include "/lib/get_shadow.glsl"

void main() {
    vec4 albedo = texture(colortex1, texcoord);
    
    vec3 lightmap = texture(colortex3, texcoord).rgb;
    
    vec3 normal = texture(colortex4, texcoord).rgb;
    vec3 normalViewspace = view(normal);

    #if defined ENABLE_SHADOWS
        vec3 position = texture(colortex5, texcoord).rgb;
        float shadow = getShadow(position, shadowProjection, shadowModelView, shadowtex0, lightmap.g);
    #else
        float shadow = 1;
    #endif

    vec3 lightColor = getLightColor(shadow, lightmap, normal, normalViewspace, sunPosition, moonPosition, moonPhase, worldTime, rainStrength);

    #if !defined DEBUG_VIEW
        albedo.rgb *= lightColor;
    #endif

    b1 = albedo;
}