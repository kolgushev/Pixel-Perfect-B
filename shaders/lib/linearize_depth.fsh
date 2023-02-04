// credit to https://wiki.shaderlabs.org/wiki/Shader_tricks for the optimized formula
float linearizeDepth(in float depth, in float near, in float far) {
    // unoptimized EQ: (near * far) / (depth * (near - far) + far)
	return (near * far) / (depth * (near - far) + far);	
}