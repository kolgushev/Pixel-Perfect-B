#include "/common_defs.glsl"

layout(location = 0) out vec4 buffer0;

in vec2 texcoord;
uniform sampler2D colortex0;


void main() {
    vec4 albedo = texture(colortex0, texcoord);
    buffer0 = albedo;
}