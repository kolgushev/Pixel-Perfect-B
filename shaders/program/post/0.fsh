// Figure out weird textures and generate our own

#define data_pass

#include "/lib/common_defs.glsl"
#include "/program/base/configure_buffers.fsh"

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
const bool colortex0Clear = true;

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

void main() {
    #define READ_DEPTH
    
    #define READ_ALBEDO
    #define WRITE_ALBEDO
    
    #define READ_NORMAL
    #define WRITE_NORMAL
    
    #define READ_LIGHTMAP
    #define OVERRIDE_LIGHTMAP

    #define READ_MASKS
    #define OVERRIDE_MASKS
    
    #define READ_GENERIC
    #define WRITE_GENERIC
    
    #define READ_GENERIC2
    #define WRITE_GENERIC2
    
    #define READ_GENERIC3
    #define WRITE_GENERIC3
    
    #define WRITE_COORD
    
    #include "/program/base/passthrough_1_unalign.fsh"

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
    vec3 normalWorldSpace = normal;
    
    /* reconstruct position for entities */
    if(terrainMask < 0.5 && skyMask < 0.5) {
        generic.xyz = viewInverse(getViewSpace(gbufferProjectionInverse, texcoord, depth));
    }
    vec3 worldSpace = generic.xyz;

    /* find facing ratio */

    // convert texcoord to worldspace (essentially reconstructing a per-pixel camera view direction)
    vec4 deprojectedTexcoordRaw = gbufferProjectionInverse * texcoordTransformed;
    vec3 deprojectedTexcoord = filter3D(deprojectedTexcoordRaw);
    vec4 worldSpaceTexcoordRaw = gbufferModelViewInverse * deprojectedTexcoordRaw;
    vec3 worldSpaceTexcoord = filter3D(worldSpaceTexcoordRaw);

    // get facing vector
    vec3 screenToGeometryVector = normalize(worldSpace - worldSpaceTexcoord);
    
    vec3 discreteFacingRatio = abs(normalWorldSpace * screenToGeometryVector);
    float facingRatio = abs(dot(normalWorldSpace, screenToGeometryVector));
    discreteFacingRatio = vec3(mix(1f, discreteFacingRatio.x, abs(normalWorldSpace.x)), mix(1f, discreteFacingRatio.y, abs(normalWorldSpace.y)), mix(1f, discreteFacingRatio.z, abs(normalWorldSpace.z)));

    /* find whether the texel in the current pixel is smaller than the pixel */

    // create up and down vectors and affect by directionalFacingRatio 
    vec3 tangentVector = discreteFacingRatio * viewInverse(vec3(1, 0, 0));
    vec3 cotangentVector = discreteFacingRatio * viewInverse(vec3(0, 1, 0));

    // sample a position one texel to the side of the current position
    dvec3 tangentSample = fma(tangentVector, vec3(TEX_RES), worldSpace);
    dvec3 cotangentSample = fma(cotangentVector, vec3(TEX_RES), worldSpace);

    // map the position to xy coords on the screen
    dvec4 pixelWidthRaw = viewTransform(tangentSample);
    dvec4 pixelHeightRaw = viewTransform(cotangentSample);
    float pixelWidth = float(abs(filter2D(pixelWidthRaw).x - texcoordTransformed.x));
    float pixelHeight = float(abs(filter2D(pixelHeightRaw).y - texcoordTransformed.y));
    
    texelSurfaceArea = pixelWidth * pixelHeight;

    // check if the resulting 2D sample position is further than a pixel away from current pos
    bool smallerThanPixel = pixelWidth * viewHeight <= 1 && pixelHeight * viewWidth <= 1;

    // albedo = opaque(mix(albedo.xyz, vec3(0), float(smallerThanPixel)));
    // albedo = opaque1(pixelHeight * 100);
    // albedo = opaque(tangentVector);


    // note: texpix rendering is a term I made up that refers to one pixel being rendered per onscreen texel
    /* Create the render and position texture maps for texpix rendering */
    
    texcoordMod = texcoord;
    // 0 = don't render, 0<n<1 = render as usual, 1 = render 
    renderable = 0.5;
    #if defined TEX_RENDER || defined DEBUG_VIEW
        if(!smallerThanPixel && terrainMask > 0.5) {
            // note: pixel refers to pixels on the screen, texel refers to the pixels on a minecraft texture

            // TODO: rotate virtual voxels based on normals (that's why we're taking the modulo here)
            dvec3 cameraPosTiled = mod(cameraPosition, 1);

            dvec3 currentDistMap = worldSpace + cameraPosTiled;

            // create a distance map with one color per texel
            dvec3 distanceMapMod = (floor(currentDistMap / TEX_RES) + 0.5) * TEX_RES - cameraPosTiled;

            // filter sides with z-fighting
            // ceil pixelates partially-rotated faces, floor excludes them
            distanceMapMod = mix(worldSpace, distanceMapMod, ceil(1 - abs(normalWorldSpace)));

            // convert to clipspace
            dvec4 distanceMapModClipspace = viewTransform(distanceMapMod);
            dvec2 texMod = vec2(filter2D(distanceMapModClipspace) * 0.5 + 0.5); 
            vec2 resolutionScaler = vec2(viewWidth, viewHeight);

            // snap value to nearest pixel
            vec2 modRes = clamp(vec2(floor(texMod * resolutionScaler)), vec2(0), resolutionScaler);
            vec2 res = clamp(vec2(floor(texcoord * resolutionScaler)), vec2(0), resolutionScaler);
            
            // determine rendered pixel (only the pixel closest to the center of the texel should be rendered)
            if(modRes == res) renderable = 1;
            else renderable = 0;
            
            texMod = (dvec2(modRes) + 0.5) / resolutionScaler;

            texcoordMod = vec2(texMod);

            // albedo = opaque(vec3(mix(vec2(0), texMod, renderable), 0));
        }
    #endif

    /* transfer the normal map to worldspace */
    normal = normalWorldSpace;

    /* reproject textures from previous frame */
    
    // remap coord buffer (used to avoid clearing generics)
    float prevDist = generic2.r;
    vec3 velocity = vec3(coord.ba, lightmap.a);

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
    // albedo = opaque1(approachOne(generic2.a));
    // albedo = opaque1(masks.b + 0.1);

    #ifndef TEX_RENDER
        renderable = 0.5;
    #endif

    #include "/program/base/passthrough_2.fsh"
}
