#include "/lib/common_defs.glsl"

layout(location = 0) out vec4 buffer0;

#include "/program/base/samplers.fsh"

void main() {
    vec4 albedo = texture(colortex0, texcoord);
    buffer0 = albedo;
}