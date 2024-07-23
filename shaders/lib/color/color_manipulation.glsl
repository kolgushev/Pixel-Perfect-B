// kelvin to RGB code adapted from https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
vec3 kelvinToColor(in float actualTemp) {
    // divide by 100 to get a workable number
    float temp = actualTemp * 0.01;
    
    // original equations have been converted to use a range of 0-1 rather than 0-255
    vec3 color = temp < 66 ? vec3(
            1,
            0.3900815787690196 * log(max(temp, EPSILON)) - 0.6318414437886275,
            (0.5432067891102 * log(max(temp - 10, EPSILON)) - 1.19625408914)) : vec3(
            1.292936186062745 * pow(temp - 60, -0.1332047592),
            1.292936186062745 * pow(temp - 60, -0.1332047592),
            1);

    return sRGBToACEScg(clamp(color, vec3(0.0), vec3(1.0)));
}

// thanks to https://www.rapidtables.com/convert/color/rgb-to-cmyk.html for CMYK calculations
vec4 RGBToCMYK(in vec3 rgb) {
    float black = 1 - max(max(rgb.r, rgb.g), rgb.b);
    float cyan = (1 - black - rgb.r) / (1 - black);
    float magenta = (1 - black - rgb.g) / (1 - black);
    float yellow = (1 - black - rgb.b) / (1 - black);

    return vec4(cyan, magenta, yellow, black);
}

vec3 CMYKToRGB(in vec4 cmyk) {
    float white = 1 - cmyk.w;
    float red = (1 - cmyk.x) * white;
    float green = (1 - cmyk.y) * white;
    float blue = (1 - cmyk.z) * white;

    return vec3(red, green, blue);
}