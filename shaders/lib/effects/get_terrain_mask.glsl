float getCutoutMask(in float mcEntity) {
    return 2
   +  float(mcEntity == CUTOUTS)
   +  float(mcEntity == LIT_CUTOUTS)
   +  float(mcEntity == LIT_PARTIAL_CUTOUTS)
   +  float(mcEntity == WAVING_CUTOUTS_BOTTOM)
   +  float(mcEntity == WAVING_CUTOUTS_TOP)
   +  float(mcEntity == WAVING_CUTOUTS_BOTTOM_STIFF)
   +  float(mcEntity == WAVING_CUTOUTS_TOP_STIFF)
   -  float(mcEntity == CUTOUTS_UPSIDE_DOWN)
   -  float(mcEntity == LIT_CUTOUTS_UPSIDE_DOWN)
   -  float(mcEntity == LIT_PARTIAL_CUTOUTS_UPSIDE_DOWN);
}