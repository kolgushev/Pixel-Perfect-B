#include "/lib/common_defs.glsl"

in vec2 texcoord;

uniform sampler2D colortex1;

layout(location = 1) out vec4 b1;

#include "/lib/to_viewspace.glsl"
#include "/lib/linearize_depth.fsh"
#include "/lib/tonemapping.glsl"

// 211
void main() {
    b1 = texture(colortex1, texcoord);
}