vec3 getFogColor(int isEyeInWater, vec3 defaultColor) {
	switch(isEyeInWater) {
		/*
			case 1 (water) is not included since water is transparent,
			which means looking up at the sky from below the water would look really awkward.
		*/
		case 2:
			return ATMOSPHERIC_FOG_COLOR_LAVA;
		case 3:
			return ATMOSPHERIC_FOG_COLOR_POWDER_SNOW;
		default:
			return defaultColor;
	}
}