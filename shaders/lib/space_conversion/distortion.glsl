// Using https://github.com/saada2006/MinecraftShaderProgramming/tree/master/Tutorial%204%20-%20Advanced%20Shadow%20Mapping
vec2 distortShadow(in vec2 position) {

    // float dist = (abs(position.x - position.y) + abs(position.x + position.y)) * 0.5;
    float dist = length(position);
    float distortion = mix(1.0, dist, SHADOW_DISTORTION);

    vec2 distortedPos = position / distortion;

    return distortedPos;
}