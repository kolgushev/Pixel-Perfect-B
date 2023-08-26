float basicDirectShading(in float skyLight) {
    return skyLight;
    return pow(clamp((skyLight - 1.0 + RCP_3) * 3.0, 0.0, 1.0), 2.0);
}