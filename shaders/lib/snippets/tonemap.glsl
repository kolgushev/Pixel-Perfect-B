// tonemap image
#if LMT_MODE == 1
	tonemapped = tonemapped * RCP_16;
#elif LMT_MODE == 2
	tonemapped = reinhard(tonemapped);
#elif LMT_MODE == 3
	tonemapped = uncharted2_filmic(tonemapped);
#elif LMT_MODE == 4
	tonemapped = aces_fitted(tonemapped);
#endif