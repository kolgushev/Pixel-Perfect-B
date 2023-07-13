vec3 lightningFlash(in float isLightning, in float rain) {
    #if !defined DIM_NO_RAIN
        return isLightning * rain * LIGHTNING_FLASHES * 25.0 * LIGHTNING_FLASH_TINT;
    #else
        return vec3(0);
    #endif
}