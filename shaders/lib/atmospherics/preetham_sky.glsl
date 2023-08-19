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

uniform vec3 preethamA, preethamB, preethamC, preethamD, preethamE, preethamZ;

// ------------------------------------------------------------------
// FUNCTIONS --------------------------------------------------------
// ------------------------------------------------------------------

vec3 perez(float cos_theta, float gamma, float cos_gamma, vec3 A, vec3 B, vec3 C, vec3 D, vec3 E)
{
    return (1 + A * exp(B / (cos_theta + 0.01))) * (1 + C * exp(D * gamma) + E * cos_gamma * cos_gamma);
}

// ------------------------------------------------------------------

vec3 preetham_sky_rgb(vec3 v, vec3 sun_dir)
{
    float cos_theta = clamp(v.y, 0, 1);
    float cos_gamma = dot(v, sun_dir);
    float gamma = acos(cos_gamma);
    
    vec3 R_xyY = preeethamZ * perez(cos_theta, gamma, cos_gamma, preeethamA, preeethamB, preeethamC, preeethamD, preeethamE);
    
    vec3 R_XYZ = vec3(R_xyY.x, R_xyY.y, 1 - R_xyY.x - R_xyY.y) * R_xyY.z / R_xyY.y;
    
    // Radiance
    float r = dot(vec3( 3.240479, -1.537150, -0.498535), R_XYZ);
    float g = dot(vec3(-0.969256,  1.875992,  0.041556), R_XYZ);
    float b = dot(vec3( 0.055648, -0.204043,  1.057311), R_XYZ);

    return vec3(r, g, b);
}

// ------------------------------------------------------------------