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

uniform vec3 p_A, p_B, p_C, p_D, p_E, p_Z;

// ------------------------------------------------------------------
// FUNCTIONS --------------------------------------------------------
// ------------------------------------------------------------------

vec3 perez(float cos_theta, float gamma, float cos_gamma, vec3 a, vec3 b, vec3 c, vec3 d, vec3 e)
{
    return (1.0 + a * exp(b / (cos_theta + 0.01))) * (1.0 + c * exp(d * gamma) + e * cos_gamma * cos_gamma);
}

// ------------------------------------------------------------------

vec3 preethamSkyVector(vec3 v, vec3 sun_dir)
{
    float cos_theta = clamp(v.y, 0.0, 1.0);
    float cos_gamma = dot(v, sun_dir);
    float gamma = acos(cos_gamma);
    
    vec3 R_xyY = p_Z * perez(cos_theta, gamma, cos_gamma, p_A, p_B, p_C, p_D, p_E);
    
    vec3 R_XYZ = vec3(R_xyY.x, R_xyY.y, 1.0 - R_xyY.x - R_xyY.y) * R_xyY.z / R_xyY.y;

    return max(R_XYZ * XYZ_to_ACEScg, 0.0);
}

// ------------------------------------------------------------------