// Sourced from https://github.com/diharaw/sky-models

/*
Copyright (c) 2019 Dihara Wijetunga

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

// ------------------------------------------------------------------
// UNIFORMS ---------------------------------------------------------
// ------------------------------------------------------------------

uniform vec3 skyA, skyB, skyC, skyD, skyE, skyF, skyG, skyH, skyI, skyZ;

// ------------------------------------------------------------------
// FUNCTIONS --------------------------------------------------------
// ------------------------------------------------------------------

vec3 hosekWilkieFormula(float cos_theta, float gamma, float cos_gamma)
{
	vec3 chi = (1 + cos_gamma * cos_gamma) / pow(1 + skyH * skyH - 2 * cos_gamma * skyH, vec3(1.5));
	return (1 + skyA * exp(skyB / (cos_theta + 0.01))) * (skyC + skyD * exp(skyE * gamma) + skyF * (cos_gamma * cos_gamma) + skyG * chi + skyI * sqrt(cos_theta));
}


// ------------------------------------------------------------------

vec3 hosekWilkieSkyVector(vec3 v, vec3 sun_dir)
{
    float cos_theta = clamp(v.y, 0, 1);
	float cos_gamma = clamp(dot(v, sun_dir), 0, 1);
	float gamma_ = acos(cos_gamma);

	vec3 R = skyZ * hosekWilkieFormula(cos_theta, gamma_, cos_gamma);
    return R * XYZ_to_ACEScg;
}

vec3 hosekWilkieSkyVector(vec3 v, vec3 sun_dir, vec2 offset) {
	float theta = acos(v.y);
	float gamma = acos(dot(v, sun_dir));
	theta += offset.x;
	gamma += offset.y;

	vec3 R = skyZ * hosekWilkieFormula(cos(theta), gamma, cos(gamma));
	return R * XYZ_to_ACEScg;
}

// ------------------------------------------------------------------