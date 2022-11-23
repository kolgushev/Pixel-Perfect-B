#include "/common_defs.glsl"


layout(location = 1) out vec3 b1;

in vec2 texcoord;

in vec3 normal;
in vec3 position;

uniform vec3 shadowLightPosition;

uniform sampler2D texture;
uniform float alphaTestRef;

uniform mat4 gbufferModelViewInverse;

void main() {
    // sign of dot product determines sign of epsilon
    vec4 albedo = texture2D(texture, texcoord);
    // throw out transparent stuff
    if(albedo.a < alphaTestRef) discard;
    // if(dot(viewInverse(shadowLightPosition), normal) > 0.0 || albedo.a < alphaTestRef) discard;

    b1 = position;
}