#include "/lib/common_defs.glsl"

layout(location = 0) out vec4 b0;

in vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex3;
uniform sampler2D colortex5;

uniform sampler2D shadowtex0;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

uniform int worldTime;

// don't need to include to_viewspace since calculate_lighting already includes it
#include "/lib/to_viewspace.glsl"
#include "/lib/get_shadow.glsl"

void main() {
    vec3 diffuse = texture(colortex0, texcoord).rgb;
    vec3 directLighting = texture(colortex1, texcoord).rgb;

    float skyLightmap = texture(colortex3, texcoord).g;
    vec3 position = texture(colortex5, texcoord).rgb;

    float shadow = getShadow(position, shadowProjection, shadowModelView, shadowtex0, skyLightmap, worldTime);

    #if defined DEBUG_VIEW
        b0 = opaque(diffuse);
    #else
        b0 = opaque(diffuse + directLighting * shadow);
    #endif
}