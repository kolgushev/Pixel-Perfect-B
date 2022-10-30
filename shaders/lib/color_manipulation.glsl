// kelvin to RGB code adapted from https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
vec3 kelvinToRGB(in float actualTemp) {
    // divide by 100 to get a workable number
    float temp = actualTemp * 0.01;
    
    // original equations have been converted to use a range of 0-1 rather than 0-255
    vec3 color = temp < 66 ? vec3(
            1,
            fma(0.3900815787690196, log(max(temp, EPSILON)), -0.6318414437886275),
            fma(0.5432067891102, log(max(temp - 10, EPSILON)), -1.19625408914)) : vec3(
            1.292936186062745 * pow(temp - 60, -0.1332047592),
            1.292936186062745 * pow(temp - 60, -0.1332047592),
            1);

    return clamp(color, 0, 1);
}