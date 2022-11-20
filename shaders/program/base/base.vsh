// process lighting
#define lighting_pass

#include "/lib/common_defs.glsl"

const float sunPathRotation = -20;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

uniform float viewWidth;
uniform float viewHeight;

// Direction of the sun (not normalized!)
uniform vec3 sunPosition;
uniform vec3 moonPosition;

uniform int worldTime;
uniform int moonPhase;
uniform float rainStrength; 

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

#if defined g_terrain
    in vec2 mc_Entity;
#endif

in vec3 vaPosition;
in vec4 vaColor;
in vec3 vaNormal;
in vec2 vaUV0;
in ivec2 vaUV2;
in vec3 at_velocity;

uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

out vec3 position;
out vec2 texcoord;
out vec4 light;
out vec3 lightSky;
out vec4 color;
out vec3 normal;

out vec4 masks;
out vec3 velocity;

out float currentSkyWhitePoint;

#if defined g_skybasic
    out vec4 stars;
#endif

#include "/lib/to_viewspace.glsl"
#include "/lib/calculate_lighting.glsl"
#include "/lib/tonemapping.glsl"

#if defined g_terrain
#include "/lib/get_terrain_mask.glsl"
#endif

void main() {
    masks = vec4(0);
    // transform vertices
    position = chunkOffset + vaPosition;
    bool entityMask = masks.g < 0.5 && masks.r < 0.5;

    gl_Position = toViewspace(projectionMatrix, modelViewMatrix, position);
    
    #ifdef g_skybasic
        stars = vec4(color.rgb, float(color.r == color.g && color.g == color.b && color.r > 0.0));
    #endif

    #if defined g_terrain
        masks.b =
            float(mc_Entity.x == LIT)
        +  float(mc_Entity.x == LIT_PROBLEMATIC) * 2
        +  float(mc_Entity.x == LIT_CUTOUTS)
        +  float(mc_Entity.x == LIT_CUTOUTS_UPSIDE_DOWN)
        +  float(mc_Entity.x == LIT_PARTIAL)
        +  float(mc_Entity.x == LIT_PARTIAL_CUTOUTS)
        +  float(mc_Entity.x == LIT_PARTIAL_CUTOUTS_UPSIDE_DOWN);
        
        // 2 - normal, 1 - upside down, 3 - right side up
        masks.g = getCutoutMask(mc_Entity.x);
    #endif

    texcoord = vaUV0;
    light = vec4((LIGHT_MATRIX * vec4(vaUV2, 1, 1)).xy, 1, 1);

    vec3 vaColorProcessed = vaColor.rgb;
    #ifdef GAMMA_CORRECT_PRE
        vaColorProcessed = gammaCorrection(vaColor.rgb, GAMMA);
    #endif
    color = opaque(vaColorProcessed * RGB_to_ACEScg);

    normal = entityMask ? viewInverse(vaNormal) : vaNormal;
    // normal = vaNormal;
    velocity = at_velocity;

    // Extract masks
    // float cutoutMask = (masks.g - 2) * CUTOUT_ALIGN_STRENGTH * (1 - float(entityMask);
    float cutoutMask = entityMask ? 0 : (masks.g - 2) * CUTOUT_ALIGN_STRENGTH;

    vec3 normalViewSpace = view(normal);
    vec3 upNormal = view(vec3(0, 1, 0));
    vec3 cutoutNormal = normalViewSpace * (1 - abs(cutoutMask)) + upNormal * cutoutMask;
    // vec3 cutoutNormal = normalViewSpace;

    // Compute dot product vertex shading from normals
    float sunShading = normalLighting(cutoutNormal, sunPosition);
    float moonShading = normalLighting(cutoutNormal, moonPosition);
    // Usually this is divided by 2, but we're dividing by more than that to simulate bounce lighting
    float skyAmount = fma((viewInverse(cutoutNormal).y - 1), RCP_3, 1f);

    // Do the lighting calculations
    vec2 lightAdjusted = max(vec2(light.rg) - 0.0313, 0);

    // adjust light level of buggy lights
    if(masks.b > 1.5) {
        lightAdjusted = vec2(1.0, lightAdjusted.g - 1);
    }

    vec3 lightColor = getLightColor(lightAdjusted, sunShading, moonShading, moonPhase, worldTime, rainStrength, skyAmount, AMBIENT_LIGHT_MULT, MIN_LIGHT_MULT);
    lightColor *= 1 - clamp((1 - pow2(vaColor.a)) * VANILLA_AO_INTENSITY, 0, 1);

    // store calculated data in lightmap
    light = vec4(lightColor, lightAdjusted.y);
}