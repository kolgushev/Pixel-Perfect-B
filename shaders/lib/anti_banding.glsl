/* Because of adaptive sampling, a different number of samples are taken based on the distance of a pixel from a camera.
Due to the way sampling and for loops work, you can only take an integer number of samples. This usually results in ugly banding,
especially when the transition happens at fewer samples (going from 1 to 2 samples is much more noticeable than 10 to 11).
To prevent this banding, we interpolate the first sample depending on the (non-int) sample rate. Is this a waste of performance?
Yes. Does it look better? Also yes. */
float antiBanding(in int i, in float samples) {
    float sampleMod = mod(samples, 1);
    return i == 0 && sampleMod != 0 ? sampleMod : 1;
}