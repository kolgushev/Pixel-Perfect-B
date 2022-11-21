#include "/lib/common_defs.glsl"

in vec2 texcoord;

uniform sampler2D colortex1;
uniform sampler2D colortex3;
uniform sampler2D colortex4;

uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform int worldTime;
uniform int moonPhase;
uniform float rainStrength; 

uniform mat4 gbufferModelView;

layout(location = 1) out vec4 b1;

#include "/lib/calculate_lighting.glsl"

// 211
void main() {
    vec4 albedo = texture(colortex1, texcoord);
    
    vec3 lightmap = texture(colortex3, texcoord).rgb;
    
    vec3 normal = texture(colortex4, texcoord).rgb;
    vec3 normalViewspace = view(normal);

    vec3 lightColor = getLightColor(lightmap, normal, normalViewspace, sunPosition, moonPosition, moonPhase, worldTime, rainStrength);
    
    albedo.rgb *= lightColor;

    b1 = albedo;
}