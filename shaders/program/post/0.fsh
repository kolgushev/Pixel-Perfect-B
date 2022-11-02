// Figure out weird textures and generate our own

#define data_pass

#include "/lib/common_defs.glsl"

layout(location = 0) out vec4 buffer0;
layout(location = 1) out vec4 buffer1;
layout(location = 5) out vec4 buffer5;
layout(location = 6) out vec4 buffer6;
layout(location = 7) out vec4 buffer7;

#include "/program/base/samplers.fsh"

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform float far;
uniform float near;
uniform float aspectRatio; 


uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;

uniform mat4 modelViewMatrix;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferPreviousProjection;

uniform mat4 projectionMatrix;

const int noiseTextureResolution = 512;

// use floats since they aren't capped at one (for easier color manipulation)
/*
const int colortex0Format = RGBA16F;
const bool colortex0Clear = false;

const int colortex1Format = RGBA16_SNORM;
const bool colortex1Clear = true;

const int colortex2Format = RGBA16F;
const bool colortex2Clear = true;

const int colortex3Format = RGBA32F;
const bool colortex3Clear = true;

const int colortex4Format = RGBA16F;
const bool colortex4Clear = true;

const int colortex5Format = RGBA32F;
const bool colortex5Clear = true;

const int colortex6Format = RGBA32F;
const bool colortex6Clear = false;

const int colortex7Format = RGBA16F;
const bool colortex7Clear = false;
*/

#include "/lib/to_viewspace.glsl"
#include "/lib/linearize_depth.fsh"
#include "/lib/tonemapping.glsl"

// masks:
// r - sky
// g - terrain / grass normals
// b - emissiveness

// coord.ba and lightmap.a combine to form velocity vectors

void main() {

    float depth = texture(depthtex0, texcoord).r;
    
    vec4 albedo = texture(colortex0, texcoord);
    vec4 normal = texture(colortex1, texcoord);
    // vec4 lightmap = texture(colortex2, texcoord);
    vec4 coord = texture(colortex3, texcoord);
    vec4 masks = vec4(texture(colortex4, texcoord));
    vec4 generic = texture(colortex5, texcoord);
    vec4 generic2 = texture(colortex6, texcoord);    
    vec4 generic3 = texture(colortex7, texcoord);

    // transfer transparent masks
    if(generic.a > 0.5) {
        masks = vec4(masks.r, coord.r, normal.a, generic.a);
    }

    // albedo = opaque(vec3(texcoordReproject, 0));
    
    /* correct textures */
    float terrainMask = float(masks.g);
    float skyMask = float(masks.r);
    // albedo = opaque(vec3(masks.rgb) / 3);

    vec4 texcoordTransformed = vec4(texcoord * 2 - 1, 0, 1);

    // more realistic albedo
    #ifdef REALISTIC_COLORS
        if(skyMask < 0.5) {
            float saturation = COLORS_SATURATION * dot(normalize(albedo.rgb), COLORS_SATURATION_WEIGHTS);
            vec3 saturated = saturateRGB(saturation) * albedo.rgb;
            vec3 contrasted = fma((saturated - COLORS_CONTRAST_BRIGHT_BIAS), vec3(COLORS_CONTRAST), vec3(COLORS_CONTRAST_BRIGHT_BIAS));
            albedo.rgb = clamp(contrasted, 0, 1);
            // albedo.rgb = normalize(albedo.rgb);
        }
    #endif
    
    /* standardize normal space */
    // terrain normals are worldspace while everything else is viewspace
    vec3 normalWorldSpace = normal.xyz;
    
    /* reconstruct position for entities */
    if(terrainMask < 0.5 && skyMask < 0.5) {
        generic.xyz = viewInverse(getViewSpace(gbufferProjectionInverse, texcoord, depth));
    }
    vec3 worldSpace = generic.xyz;

    /* transfer the normal map to worldspace */
    normal = opaque(normalWorldSpace);

    /* reproject textures from previous frame */
    
    // remap coord buffer (used to avoid clearing generics)
    float prevDist = generic2.r;
    vec3 velocity = coord.gba;

    // store 

    // find reprojection texcoord
    vec2 texcoordReproject = vec2(0);
    vec3 prevWorldSpace = vec3(0);

    if(terrainMask < 0.5 && skyMask < 0.5) {
        prevWorldSpace = viewInverse(view(worldSpace) - velocity);
        texcoordReproject = filter2D(viewTransform(prevWorldSpace));
    } else {
        prevWorldSpace = worldSpace - previousCameraPosition + cameraPosition;
        texcoordReproject = filter2D(viewTransformPrev(prevWorldSpace));
    }


    texcoordReproject = texcoordReproject * 0.5 + 0.5;


    // reproject necessary textures
    vec2 neighborSamples[4] = vec2[4](
        vec2(1, 0),
        vec2(-1, 0),
        vec2(0, 1),
        vec2(0, -1)
    );
    if(clamp(texcoordReproject, 0, 1) == texcoordReproject && skyMask < 0.5) {
        // prevent reprojection ghosting
        // float reprojectedDist = abs(prevDist - length(texture(colortex5, texcoordReproject).xyz));
        float reprojectedDist = abs(texture(colortex6, texcoordReproject).r - length(prevWorldSpace));
        
        generic3.rgb = texture(colortex7, texcoordReproject).rgb;
        generic2.gba = texture(colortex6, texcoordReproject).gba;
        
        generic2.ga = reprojectedDist > 0.13 ? vec2(0) : generic2.ga;
    } else {
        generic2.ga = vec2(0);
    }

    // albedo = opaque(vec3(approachOne(generic2.a)) * normal);
    // albedo = opaque(normal);
    // albedo = opaque1(depth);
    // albedo = opaque1(albedo.a);
    // albedo = opaque(fma(vec3(coord.ba, lightmap.a), vec3(0.5), vec3(0.5)));
    // albedo = opaque(masks.rgb / 4);
    // albedo = opaque(coord.aaa);
    // albedo = opaque(1 - (1 / (masks.aaa + 1) ) );
    // albedo = opaque(1 - (1 / (lightmap.rgb + 1) ) );
    // albedo = opaque(normal.rgb);

    buffer0 = albedo;
    buffer1 = normal;
    buffer5 = generic;
    buffer6 = generic2;
    buffer7 = generic3;
    
}
