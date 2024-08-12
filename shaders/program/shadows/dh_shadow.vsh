
#define g_vsh
#include "/common_defs.glsl"

// necessary for some function in use.glsl
attribute vec3 vaPosition;
varying vec2 texcoord;
varying vec3 position;

#include "/lib/use.glsl"

void main() {
    #if defined SHADOWS_ENABLED && defined DH_SHADOWS_ENABLED
        position = gl_Vertex.xyz;

        gl_Position = toClipspace(gl_ProjectionMatrix, gl_ModelViewMatrix, position);
        
        gl_Position.xy = distortShadow(gl_Position.xy);
    #else
        gl_Position = vec4(0);
    #endif
}