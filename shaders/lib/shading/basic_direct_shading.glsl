float basicDirectShading(in float skyLight) {
    return skyLight;
    return pow(clamp(skyLight * 3.0 - 2.0, 0.0, 1.0), 2.0);
}