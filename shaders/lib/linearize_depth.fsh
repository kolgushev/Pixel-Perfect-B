// credit to https://wiki.shaderlabs.org/wiki/Shader_tricks for the optimized formula
float linearizeDepth(in float depth, in float near, in float far) {
	return (near * far) / (depth * (near - far) + far);	
}