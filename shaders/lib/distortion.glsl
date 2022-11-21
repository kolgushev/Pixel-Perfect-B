// Using https://github.com/saada2006/MinecraftShaderProgramming/tree/master/Tutorial%204%20-%20Advanced%20Shadow%20Mapping
vec2 distortShadow(in vec2 position){
    float dist = length(position);
    float distortion = mix(1.0, dist, 0.9);
    return position / distortion;
}