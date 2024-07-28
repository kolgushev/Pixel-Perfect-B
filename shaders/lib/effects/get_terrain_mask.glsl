float getCutoutMask(in float mcEntity) {
    return 2.0 + float(isBlockCrossCutouts(mcEntity)) - float(isBlockCrossCutoutsUpsideDown(mcEntity));
}