// linear spaces (just matrix mults)
vec3 ACEScgToLinearRGB(in vec3 v) {
    return AP1_to_RGB * v;
}

vec3 linearRGBToACEScg(in vec3 v) {
    return RGB_to_AP1 * v;
}

vec3 ACEScgToACES2065_1(in vec3 v) {
    return AP1_to_AP0 * v;
}

vec3 ACES2065_1ToACEScg(in vec3 v) {
    return AP0_to_AP1 * v;
}

vec3 ACEScgToXYZ(in vec3 v) {
    return AP1_to_XYZ * v;
}

vec3 XYZToACEScg(in vec3 v) {
    return XYZ_to_AP1 * v;
}

// sRGB
vec3 sRGBOETF(in vec3 v) {
    bvec3 cutoff = lessThan(v, vec3(0.0031308));
    vec3 higher = vec3(1.055)*pow(v, vec3(0.4166666667)) - vec3(0.055);
    vec3 lower = v * vec3(12.92);

    return mix(higher, lower, cutoff);
}

vec3 sRGBOETFInverse(in vec3 v) {
    bvec3 cutoff = lessThan(v, vec3(0.04045));
    vec3 higher = pow((v + vec3(0.055)) / vec3(1.055), vec3(2.4));
    vec3 lower = v / vec3(12.92);

    return mix(higher, lower, cutoff);
}

vec3 ACEScgToSRGB(in vec3 v) {
    return sRGBOETF(AP1_to_RGB * v);
}

vec3 sRGBToACEScg(in vec3 v) {
    return RGB_to_AP1 * sRGBOETFInverse(v);
}

// Adobe RGB
vec3 adobeRGBOETF(in vec3 v) {
    return pow(v, vec3(0.4547069272));
}

vec3 adobeRGBOETFInverse(in vec3 v) {
    return pow(v, vec3(2.19921875));
}

vec3 ACEScgToAdobeRGB(in vec3 v) {
    return adobeRGBOETF(AP1_to_ADOBE_RGB * v);
}

vec3 adobeRGBToACEScg(in vec3 v) {
    return ADOBE_RGB_to_AP1 * adobeRGBOETFInverse(v);
}

// rec709/2020
vec3 rec709OETF(in vec3 v) {
    bvec3 cutoff = lessThan(v, vec3(0.018));
    vec3 higher = pow(v * 1.099, vec3(0.45)) - 0.099;
    vec3 lower = v * 4.5;

    return mix(higher, lower, cutoff);
}

vec3 rec709OETFInverse(in vec3 v) {
    bvec3 cutoff = lessThan(v, vec3(0.081));
    vec3 higher = pow(v * 0.9099181074 + 0.0900818926, vec3(2.2222222222));
    vec3 lower = v * 0.2222222222;

    return mix(higher, lower, cutoff);
}

vec3 ACEScgToRec709(in vec3 v) {
    return rec709OETF(AP1_to_RGB * v);
}

vec3 rec709ToACEScg(in vec3 v) {
    return RGB_to_AP1 * rec709OETFInverse(v);
}

vec3 ACEScgToRec2020(in vec3 v) {
    return rec709OETF(AP1_to_BT2020 * v);
}

vec3 rec2020ToACEScg(in vec3 v) {
    return BT2020_to_AP1 * rec709OETFInverse(v);
}


// rec2100
vec3 hlg(in vec3 v) {
    // constants a, b, c referenced from https://en.wikipedia.org/wiki/Hybrid_log%E2%80%93gamma
    const float a = 0.17883277;
    // float b = 1.0 - 4.0 * a;
    const float b = 0.28466892;
    // float c = 0.5 - a * log(4.0 * a)
    const float c = 0.55991073;
    
    bvec3 cutoff = greaterThan(v, vec3(RCP_12));
    vec3 e = clamp(v, 0.0, 1.0);
    
    vec3 lower = sqrt(3.0 * e);
    vec3 upper = a * log(12.0 * e - b) + c;

    return mix(lower, upper, cutoff);
}

vec3 hlgInverse(in vec3 v) {
    // constants a, b, c referenced from https://en.wikipedia.org/wiki/Hybrid_log%E2%80%93gamma
    const float aRcp = 5.5918163097;
    const float b = 0.28466892;
    const float c = 0.55991073;

    bvec3 cutoff = greaterThan(v, vec3(0.5));
    vec3 e = clamp(v, 0.0, 1.0);

    vec3 lower = e * e * RCP_3;
    vec3 upper = RCP_12 * (exp((e - c) * aRcp) + b);

    return mix(lower, upper, cutoff);
}

vec3 ACEScgToRec2100_HLG(in vec3 v) {
    return hlg(AP1_to_BT2020 * v);
}

vec3 rec2100_HLGToACEScg(in vec3 v) {
    return BT2020_to_AP1 * hlgInverse(v);
}

// DCI P3
// I know the functions have zero naming scheme, but adhering to one would reduce readability, so... TODO
vec3 DCI_P3_OETF(in vec3 v) {
    // Note: I was unable to find anything relating to an actual OETF, other than a passing mention of a 2.6 gamma curve on https://en.wikipedia.org/wiki/DCI-P3
    return pow(v, vec3(0.3846153846));
}

vec3 DCI_P3_OETFInverse(in vec3 v) {
    return pow(v, vec3(2.6));
}

vec3 ACEScgToDCI_P3(in vec3 v) {
    return DCI_P3_OETF(AP1_to_DCI_P3 * v);
}

vec3 DCI_P3ToACEScg(in vec3 v) {
    return DCI_P3_to_AP1 * DCI_P3_OETFInverse(v);
}

// Display P3
// OETF is same as sRGB
vec3 ACEScgToDisplayP3(in vec3 v) {
    return sRGBOETF(AP1_to_DISPLAY_P3 * v);
}

vec3 DisplayP3ToACEScg(in vec3 v) {
    return AP1_to_DISPLAY_P3 * sRGBOETFInverse(v);
}


// General function
vec3 ACEScgToColorspace(in vec3 v, in int id){
    switch(id){
        case DCI_P3_COLORSPACE:
            return ACEScgToDCI_P3(v);
        case DISPLAY_P3_COLORSPACE:
            return ACEScgToDisplayP3(v);
        case REC2020_COLORSPACE:
            return ACEScgToRec2020(v);
        case ADOBE_RGB_COLORSPACE:
            return ACEScgToAdobeRGB(v);
        case P3_D65_PQ_COLORSPACE:
            // TODO
            return ACEScgToDCI_P3(v);
        case REC709_COLORSPACE:
            return ACEScgToRec709(v);
        case REC2100_HLG_COLORSPACE:
            return ACEScgToRec2100_HLG(v);
        case REC2100_PQ_COLORSPACE:
            // TODO
            return ACEScgToRec2100_HLG(v);
        case ACEScg_COLORSPACE:
            return v;
        case ACES2065_1_COLORSPACE:
            return ACEScgToACES2065_1(v);
        case LINEAR_RGB_COLORSPACE:
            return ACEScgToLinearRGB(v);
        case XYZ_COLORSPACE:
            return ACEScgToXYZ(v);

        case SRGB_COLORSPACE:
        default:
            return ACEScgToSRGB(v);
    }
}

vec3 colorspaceToACEScg(in vec3 v, in int id){
    switch(id){
        case DCI_P3_COLORSPACE:
            return DCI_P3ToACEScg(v);
        case DISPLAY_P3_COLORSPACE:
            return DisplayP3ToACEScg(v);
        case REC2020_COLORSPACE:
            return rec2020ToACEScg(v);
        case ADOBE_RGB_COLORSPACE:
            return adobeRGBToACEScg(v);
        case P3_D65_PQ_COLORSPACE:
            // TODO
            return DCI_P3ToACEScg(v);
        case REC709_COLORSPACE:
            return rec709ToACEScg(v);
        case REC2100_HLG_COLORSPACE:
            return rec2100_HLGToACEScg(v);
        case REC2100_PQ_COLORSPACE:
            // TODO
            return rec2100_HLGToACEScg(v);
        case ACEScg_COLORSPACE:
            return v;
        case ACES2065_1_COLORSPACE:
            return ACES2065_1ToACEScg(v);
        case LINEAR_RGB_COLORSPACE:
            return linearRGBToACEScg(v);
        case XYZ_COLORSPACE:
            return XYZToACEScg(v);

        case SRGB_COLORSPACE:
        default:
            return sRGBToACEScg(v);
    }
}
