float getSamples(in float initial, in float renderable, in float pixelSize) {
    float samples = initial;

    if(renderable == 1) {
        samples = clamp(pixelSize * initial, MIN_SAMPLES, MAX_SAMPLES);
    }

    return samples;
}