// Using https://github.com/saada2006/MinecraftShaderProgramming/tree/master/Tutorial%204%20-%20Advanced%20Shadow%20Mapping
vec2 distortShadow(in vec2 position) {

    // float dist = (abs(position.x - position.y) + abs(position.x + position.y)) * 0.5;
    float dist = length(position);
    float distortion = mix(1.0, dist, SHADOW_DISTORTION + (1.0 - SHADOW_DISTORTION) * smoothstep(0.0, shadowDistance, dist));

    return position / distortion;
}

vec2 distortShadowDH(in vec2 position) {
    return (position * (SHADOW_DISTANCE / DH_SHADOW_DISTANCE) * 0.5 + 0.5) * (0.5 - 0.5 * ISQRT_2) * 2.0 - 1.0;
}