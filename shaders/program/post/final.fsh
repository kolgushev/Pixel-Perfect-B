#include "/common_defs.glsl"

layout(location = 0) out vec4 buffer0;

in vec2 texcoord;
uniform sampler2D colortex0;

#if defined SHADOW_DEBUG
    uniform sampler2D shadowcolor1;

    uniform int viewWidth;
    uniform int viewHeight;

    uniform sampler2D noisetex;

    #include "/lib/to_viewspace.glsl"
    #include "/lib/sample_noisetex.glsl"
    #include "/lib/get_shadow.glsl"
#endif

void main() {
    vec4 albedo = texture(colortex0, texcoord);
    buffer0 = albedo;

    #if defined SHADOW_DEBUG
        vec2 texcoordMod = supersampleSampleShift(texcoord);
        buffer0 = opaque1(texture(shadowcolor1, (texcoordMod - 0.5) * 0.2 + 0.5).r);
    #endif
}