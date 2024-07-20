// Note: dh_base is separate from base due to issues with the GLSL version used by everything else
#define g_vsh
#include "/common_defs.glsl"

attribute vec3 vaPosition;
attribute vec2 vaUV0;
attribute ivec2 vaUV2;
attribute vec4 vaColor;
attribute vec3 vaNormal;

varying vec2 texcoord;
varying vec4 color;
varying vec2 light;
varying vec3 position;
varying vec3 normal;
flat varying int mcEntity;

#if defined TAA_ENABLED
    varying vec3 prevClip;
    varying vec3 unjitteredClip;
#endif

#if defined g_skybasic
    varying vec2 stars;
#endif

#if defined g_clouds && defined IS_IRIS
    varying float cloudsVert;
#endif

attribute vec3 at_velocity;

#if defined gc_terrain
    attribute vec3 at_midBlock;
#endif

#include "/lib/use.glsl"

void main() {
    mcEntity = dhMaterialId;

    // all the va-stuff is nonexistent in this version, so we'll have to use built-in variables
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	light = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color = gl_Color;
    normal = normalize((gbufferModelViewInverse * vec4(gl_NormalMatrix * gl_Normal, 0.0)).xyz);

    /*
    The Optifine-provided lightmap is actually what is used to sample the
    vanilla lighting texture, so it isn't in a 0-1 range by default.
    */
    #if VANILLA_LIGHTING == 2
        light = max(light - 0.0313, 0) * 1.067;
    #endif

    position = gl_Vertex.xyz;

    #if defined DIM_END
        if(END_WARPING > 0.0) {
            float displacement = tile((position.xz + cameraPosition.xz + EPSILON) * 0.1, NOISE_PERLIN_4D, false).x - 0.5;
            position.y *= pow(pow(position.x, 2) + pow(position.z, 2), 0.02 * END_WARPING);
            position.y += displacement * (length(position.xz) * 0.2) * END_WARPING;
        }
    #endif

    // glPos is in viewspace
    vec3 glPos = playerToView(position);

    #if (PANORAMIC_WORLD == 1 || PANORAMIC_WORLD == 2)
        float yaw = atan(glPos.x, -glPos.z);
        float absYaw = abs(yaw);

        #if PANORAMIC_WORLD == 2
            // mult * some value 0.5<n<=1
            yaw = yaw * 0.6;
        #elif PANORAMIC_WORLD == 1
            yaw = mix(absYaw, 0.5 * absYaw + 0.3, smoothstep(0.5, 2.4, absYaw)) * sign(yaw);
        #endif

        glPos.xz = vec2(sin(yaw), -cos(yaw)) * length(glPos.xz);

        #if PANORAMIC_WORLD == 2
            const float n = 3;
            glPos.x /= glPos.z * n;
            glPos.x = mix(glPos.x * (1.5 - 0.5 * abs(glPos.x)), glPos.x, pow(glPos.x, 2));
            glPos.x *= glPos.z * n;
        #endif
    #endif

    vec4 glPosClip = viewToClip(glPos);

    // apply jittering
    #if defined TAA_ENABLED    
        #if !defined NO_AA
            // jitter
            glPosClip.xy += temporalAAOffsets[frameCounter % TAA_OFFSET_LEN] * glPosClip.w / vec2(viewWidth, viewHeight);
        #endif

        // Calculate clip-space for motion vectors in here since it's more efficient

        // Camera positions are subtracted first in order to reduce floating-point inaccuracies
        vec3 cameraDiff = cameraPosition - previousCameraPosition;

        vec3 unjitteredView = playerToView(position);

        prevClip = toViewspace(dhPreviousProjection, gbufferPreviousModelView, position + cameraDiff).xyw;

        unjitteredClip = viewToClip(unjitteredView).xyw;
    #endif
	
    gl_Position = glPosClip;

    #if ISOLATE_RENDER_STAGE != -1
        if(renderStage != ISOLATE_RENDER_STAGE) {
            gl_Position = vec4(0);
        }
    #endif

    #if defined NO_SHADING
        normal = vec3(0, 1, 0);
    #endif
}