vec3 makeCells(in float imax) {
    float actualCells1D = floor(sqrt(imax));
    float actualCells = pow2(actualCells1D);
    return vec3(vec2(1) / actualCells1D, actualCells);
}

vec2 grid(in float i, in vec2 cells) {
    float xPos = i * cells.x;
    return vec2(fract(xPos), floor(xPos) * cells.y);
}

vec2 jitter(in vec2 noise, in float i, in vec3 cells) {
    if(i <= cells.z) {
        vec2 node = grid(i, cells.xy);
        return cells.xy * noise + node;
    } else {
        return noise;
    }
}