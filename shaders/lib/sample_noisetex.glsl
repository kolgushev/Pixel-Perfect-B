#define NOISE_BLUE_1D 0
#define NOISE_BLUE_2D 1
#define NOISE_BLUE_3D 2
#define NOISE_BLUE_4D 3

#define NOISE_PERLIN_4D 4
#define NOISE_CHECKERBOARD_1D 5
#define NOISE_WHITE_4D 6

vec4 tile(in vec2 texcoord, in int id, in bool sharp) {


	if(sharp) {
		texcoord = floor(texcoord) + 0.5;
		texcoord /= NOISETEX_TILES_RES;
	} else {
		texcoord /= NOISETEX_TILES_RES;
	}
	
	return texture3D(noisetex, vec3(texcoord, removeBorder(float(id) / float(NOISE_LAYER_COUNT - 1), 1.0 / float(NOISE_LAYER_COUNT))));
}