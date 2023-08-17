// Credit to the linked tonemapping papers for the below code:
// https://64.github.io/tonemapping/
// https://learnopengl.com/Advanced-Lighting/HDR

// operates on RGB
float luminance(in vec3 v) {
    return dot(v, LUMINANCE_COEFFS);
}

vec3 changeLuminance(in vec3 c_in, in float l_in, in float l_out) {
    return c_in * (l_out / l_in);
}

vec3 reinhard(in vec3 v) {
    float originalLum = luminance(v);
    float newLum = originalLum / (1.0 + originalLum);
    return changeLuminance(v, originalLum, newLum);
}

vec3 reinhardInverse(in vec3 v) {
    float originalLum = luminance(v);
    float newLum = originalLum / (1.0 - min(originalLum, 1.0 - EPSILON));
    return changeLuminance(v, originalLum, newLum);
}

vec3 uncharted2_tonemap_partial(in vec3 x)
{
    const float a = 0.15;
    const float b = 0.50;
    const float c = 0.10;
    const float d = 0.20;
    const float e = 0.02;
    const float f = 0.30;
    return ((x*(a*x+c*b)+d*e)/(x*(a*x+b)+d*f))-e/f;
}

vec3 uncharted2_filmic(in vec3 v)
{
    float exposure_bias = 2.0;
    vec3 curr = uncharted2_tonemap_partial(v * exposure_bias);

    const vec3 W = vec3(11.2);
    vec3 white_scale = vec3(1.0) / uncharted2_tonemap_partial(W);
    return curr * white_scale;
}

vec3 aces_approx(in vec3 v)
{
    v *= 0.6f;
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return (v*(a*v+b))/(v*(c*v+d)+e);
}

// adapted for GLSL from https://github.com/TheRealMJP/BakingLab/blob/master/BakingLab/ACES.hlsl

//=================================================================================================
//
//  Baking Lab
//  by MJP and David Neubelt
//  http://mynameismjp.wordpress.com/
//
//  All code licensed under the MIT license
//
//=================================================================================================

// The code in this file was originally written by Stephen Hill (@self_shadow), who deserves all
// credit for coming up with this fit and implementing it. Buy him a beer next time you see him. :)

vec3 rtt_and_odt_fit(in vec3 v) {
    vec3 a = v * (v + 0.0245786) - 0.000090537;
    vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    return a / b;
}

// Inputs and outputs have been transformed to operate on the CAT02 ACEScg colorspace
vec3 aces_fitted(in vec3 v)
{
    v = v * ACEScg_to_RRT_SAT;
    v = rtt_and_odt_fit(v);
    return v * RRT_SAT_to_ACEScg;
}

// found courtesy of wolfram|alpha
vec3 rtt_and_odt_fit_inverse(in vec3 v) {
    vec3 a = v - 1.01654;
    vec3 b = -0.220056 * (v - 0.0567699);
    vec3 c = 3.21458e-8 * sqrt(-1.87346e14 * pow(v, vec3(2)) + 2.32671e14 * v + 2.41564e11);

    // technically (b ± c) / a but we don't need negative values
    return (b - c) / a;
}

// expects v to be in linear ACEScg (AP1 primaries)
vec3 aces_fitted_inverse(in vec3 v) {
    v = v * RRT_SAT_to_ACEScg_INVERSE;
    // bring v into a range such that the output of rtt_and_odt_fit_inverse is between zero and one
    v *= 0.619 / 1.00007;
    v = rtt_and_odt_fit_inverse(v);
    return v * ACEScg_to_RRT_SAT_INVERSE;
}

vec3 uncharted2_filmic_inverse(in vec3 y) {
    // bring y into a range such that the output of the equation is between zero and one
    y = y * 0.493;
    return (-0.833333 * sqrt(1895912086208.0 * y * y + 206886131312.0 * y + 4680270125.0) - 1.06161e6 * y + 57010.4) / (sqrt(1895912086208.0 * y * y + 206886131312.0 * y + 4680270125.0) - 1.84714e6);
}