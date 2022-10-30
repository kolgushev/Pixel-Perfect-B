#include "/lib/common_defs.glsl"
#include "/program/base/configure_buffers.fsh"

#include "/program/base/samplers.fsh"

void main() {
    #define READ_ALBEDO
    #define WRITE_ALBEDO
    #include "/program/base/passthrough_1.fsh"
    #include "/program/base/passthrough_2.fsh"
}