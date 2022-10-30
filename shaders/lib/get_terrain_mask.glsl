float getCutoutMask(in float mcEntity) {
    return 2
   +  float(mcEntity == CUTOUTS)
   +  float(mcEntity == LIT_CUTOUTS)
   +  float(mcEntity == LIT_PARTIAL_CUTOUTS)
   -  float(mcEntity == CUTOUTS_UPSIDE_DOWN)
   -  float(mcEntity == LIT_CUTOUTS_UPSIDE_DOWN)
   -  float(mcEntity == LIT_PARTIAL_CUTOUTS_UPSIDE_DOWN);
}