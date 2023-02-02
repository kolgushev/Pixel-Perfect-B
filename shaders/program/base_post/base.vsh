in vec3 vaPosition;
in vec2 vaUV0;

out vec2 texcoord;

void main() {
   // transform vertices
   vec4 position = vec4(vaPosition * 2 - 1, 1.0);

   gl_Position = position;
   texcoord = vaUV0;
}