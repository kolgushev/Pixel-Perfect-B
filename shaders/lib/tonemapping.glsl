// Credit to the linked tonemapping papers for the below code:
// https://64.github.io/tonemapping/
// https://learnopengl.com/Advanced-Lighting/HDR

float luminance(in vec3 v) {
    return dot(v, LUMINANCE_COEFFS);
}

vec3 changeLuminance(in vec3 c_in, in float l_in, in float l_out) {
    return c_in * (l_out / l_in);
}

vec3 gammaCorrection(in vec3 x, in float gammaInverse) {
    return pow(x, vec3(gammaInverse));
}

vec3 reinhard(in vec3 v) {
    float originalLum = luminance(v);
    float newLum = originalLum / (1.0 + originalLum);
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
    float exposure_bias = 2.0f;
    vec3 curr = uncharted2_tonemap_partial(v * exposure_bias);

    const vec3 W = vec3(11.2f);
    vec3 white_scale = vec3(1.0f) / uncharted2_tonemap_partial(W);
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

vec3 rtt_and_odt_fit(in vec3 v) {
    vec3 a = v * (v + 0.0245786) - 0.000090537;
    vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    return a / b;
}

vec3 aces_fitted(in vec3 v)
{
    v = v * ACES_INPUT;
    v = rtt_and_odt_fit(v);
    return v * ACES_OUTPUT;
}