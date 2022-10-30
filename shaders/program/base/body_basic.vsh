// transform vertices
position = chunkOffset + vaPosition;
bool entityMask = masks.g < 0.5 && masks.r < 0.5;


gl_Position = toViewspace(projectionMatrix, modelViewMatrix, position);
texcoord = vaUV0;
light = vec3((LIGHT_MATRIX * vec4(vaUV2, 1, 1)).xy, 1);
color = vec4(vaColor.rgb * sRGB_to_ACEScg, vaColor.a);
normal = entityMask ? viewInverse(vaNormal) : vaNormal;
// normal = vaNormal;
velocity = at_velocity;

// Extract masks
// float cutoutMask = (masks.g - 2) * CUTOUT_ALIGN_STRENGTH * (1 - float(entityMask);
float cutoutMask = entityMask ? 0 : (masks.g - 2) * CUTOUT_ALIGN_STRENGTH;

vec3 normalViewSpace = view(normal);
vec3 upNormal = view(vec3(0, 1, 0));
vec3 cutoutNormal = normalViewSpace * (1 - abs(cutoutMask)) + upNormal * cutoutMask;
// vec3 cutoutNormal = normalViewSpace;

// Compute dot product vertex shading from normals
float sunShading = normalLighting(cutoutNormal, sunPosition);
float moonShading = normalLighting(cutoutNormal, moonPosition);
// Usually this is divided by 2, but we're dividing by more than that to simulate bounce lighting
float skyAmount = fma((viewInverse(cutoutNormal).y - 1), RCP_3, 1f);

// Do the lighting calculations
vec2 lightAdjusted = max(vec2(light.rg) - 0.0313, 0);

vec4 lightColor = getLightColor(lightAdjusted, sunShading, moonShading, moonPhase * RCP_7, worldTime, rainStrength, skyAmount, AMBIENT_LIGHT_MULT, MIN_LIGHT_MULT);

// sky light affects bounce light
#ifndef COLORED_LIGHT_ONLY
    masks.a = lightColor.a;
#endif

// store calculated data in lightmap
light = lightColor.rgb;
// color = opaque(lightColor.rgb);