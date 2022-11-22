#include "/lib/common_defs.glsl"

layout(location = 1) out vec3 b1;

in vec2 texcoord;

in vec3 normal;

uniform vec3 shadowLightPosition;

uniform sampler2D texture;
uniform float alphaTestRef;

uniform mat4 gbufferModelViewInverse;

void main() {
    vec4 albedo = texture2D(texture, texcoord);
    // only render backfaces (frontface culling) and throw out transparent stuff
    if(dot(viewInverse(shadowLightPosition), normal) > 0.0 || albedo.a < alphaTestRef) discard;
    b1 = normal.rgb;
}