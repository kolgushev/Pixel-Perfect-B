#define defs

/*
NOTE: Any color values that aren't multiplied by a color trasform (eg. RGB_to_AP1)
    are expected to be in the ACEScg colorspace.
*/

// include defs from other files
#include "/alias_setup.glsl"
#include "/LUTs/lut_meta.glsl"
#include "/tex/noise/noise_meta.glsl"

// constants

#define EPSILON 0.001
#define EPSILON_2 0.0001
#define EPSILON_3 0.00001
#define E 2.7182818284
#define PI 3.1415926538
#define RCP_PI 0.318309886184
#define SQRT_2 1.4142135624
#define ISQRT_2 0.7071067812
#define SQRT_3 1.73205080757
#define ISQRT_3 0.57735026919
#define SQRT_5 2.2360679775
#define ISQRT_5 0.4472135955
#define RCP_3 0.33333333333
#define RCP_7 0.14285714285
#define RCP_8 0.125
#define RCP_12 0.0833333333
#define RCP_16 0.0625
#define RCP_32 0.03125
#define RCP_64 0.015625
#define RCP_255 0.00392156862
#define RCP_256 0.00390625

// multiply glsl log by these to change the logarithm's base
// found with [1 / ln(<base>)] for [CHANGE_BASE_<base>]
#define CHANGE_BASE_10 0.434294481903
#define CHANGE_BASE_2 1.44269504089

#define GAMMA 2.2
#define RCP_GAMMA 0.45454545455

// approx. fresnel reflectances
#define REFLECTANCE_PLASTIC 0.035
#define REFLECTANCE_WATER 0.02

#define LIGHT_MATRIX mat4(vec4(0.00390625, 0.0, 0.0, 0.0), vec4(0.0, 0.00390625, 0.0, 0.0), vec4(0.0, 0.0, 0.00390625, 0.0), vec4(0.03125, 0.03125, 0.03125, 1.0))
#define IDENTITY_MATRIX mat4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0)

#define UP vec3(0.0, 1.0, 0.0)

// utils

#define apow2(n) ((n) * abs(n))

#define approachOne(v) ((v) / (1 + (v)))
// multiply mat4 by vec3 (vec3.xyz, 1)
// When tested on an RTX3080ti, this actually made the mult slower
// doing this may be faster on older hardware, but make sure to test before enabling
#define OPTIMIZE_MUL 0
#if OPTIMIZE_MUL == 1
    #define mul_m4_v3(m, v) ((v).xxxx * (m)[0] + ((v).yyyy * (m)[1] + ((v).zzzz * (m)[2] + (m)[3])))
#else
    #define mul_m4_v3(m, v) ((m) * vec4(v, 1))
#endif

#define average2(a, b) (((a) + (b)) / 2)
#define rot(t) mat2(cos(t), -sin(t), sin(t), cos(t))
#define signedPow(n, e) (sign(n) * pow(abs(n), e))

#define view(a) vec4(mul_m4_v3(gbufferModelView, a)).xyz
#define viewInverse(a) vec4(mul_m4_v3(gbufferModelViewInverse, a)).xyz
#define project(a) vec4(mul_m4_v3(gbufferProjection, a)).xyz
#define projectInverse(a) vec4(mul_m4_v3(gbufferProjectionInverse, a)).xyz
#define viewTransform(a) (gbufferProjection * mul_m4_v3(gbufferModelView, a))
#define viewTransformInverse(a) vec4(gbufferModelViewInverse * mul_m4_v3(gbufferProjectionInverse, a)).xyz
#define viewTransformPrev(a) (gbufferPreviousProjection * mul_m4_v3(gbufferPreviousModelView, a))
#define filter2D(a) ((a).xy / (a).w)
#define filter2D2(a) ((a).xy / (a).z)
#define filter3D(a) ((a).xyz / (a).w)
#define filter4D(a) vec4(((a).xyz / (a).w), 1)


#define opaque(a) vec4(a, 1)
#define transparent(a) vec4(a, 0)
#define opaque1(a) vec4(a, a, a, 1)
#define transparent1(a) vec4(a, a, a, 0)
#define opaque2(a) vec4(a, 0, 1)
#define opaque3(a, b, c) vec4(a, b, c, 1)

// credit to https://beesbuzz.biz/code/16-hsv-color-transforms for the next few hsv-related defs
#define toYIQ mat3(0.299, 0.587, 0.114, 0.596, -0.274, -0.321, 0.211, -0.523, 0.311)
#define toRGB mat3(1, 0.956, 0.621, 1, -0.272, -0.647, 1, -1.107, 1.705)
#define saturateYIQ(s) mat3(1, 0, 0, 0, (s), 0, 0, 0, (s))
// math notation:
// \begin{pmatrix}0.299&0.587&0.114\\ 0.596&-0.274&-0.321\\ 0.211&-0.523&0.311\end{pmatrix}
// \begin{pmatrix}1&0.956&0.621\\ 1&-0.272&-0.647\\ 1&-1.107&1.705\end{pmatrix}
// \begin{pmatrix}1&0&0\\ 0&s&0\\ 0&0&s\end{pmatrix}

// \begin{pmatrix}0.299+0.700807s&0.299-0.298629s&0.299-0.300017s\\ 0.587-0.586727s&0.587+0.412909s&0.587-0.588397s\\ 0.114-0.113745s&0.114-0.113905s&0.114+0.885602s\end{pmatrix}
#define saturateRGB(s) mat3(0.299 + 0.700807 * (s), 0.299 - 0.298629 * (s), 0.299 - 0.300017 * (s), 0.587 - 0.586727 * (s), 0.587 + 0.412909 * (s), 0.587 - 0.588397 * (s), 0.114 - 0.113745 * (s), 0.114 - 0.113905 * (s), 0.114 + 0.885602 * (s))
// (u, w) from original paper replaced with (cos(h), sin(h)) since setting hue is more useful than modifying
#define hue(h) vec2(cos(h), sin(h))
#define transformHSV(h, s, v) mat3(0.299*(v)+0.701*(v)*(s)*(h).x+0.168*(v)*(s)*(h).y,0.587*(v)-0.587*(v)*(s)*(h).x+0.330*(v)*(s)*(h).y,0.114*(v)-0.114*(v)*(s)*(h).x-0.497*(v)*(s)*(h).y,0.299*(v)-0.299*(v)*(s)*(h).x-0.328*(v)*(s)*(h).y,0.587*(v)+0.413*(v)*(s)*(h).x+0.035*(v)*(s)*(h).y,0.114*(v)-0.114*(v)*(s)*(h).x+0.292*(v)*(s)*(h).y,0.299*(v)-0.3*(v)*(s)*(h).x+1.25*(v)*(s)*(h).y,0.587*(v)-0.588*(v)*(s)*(h).x-1.05*(v)*(s)*(h).y,0.114*(v)+0.886*(v)*(s)*(h).x-0.203*(v)*(s)*(h).y)
// attribution end

// #define nightEffect(n, l) ((n) - inversesqrt(l))
// #define nightEffect(n, l) ((l) * (n))
#define nightEffect(n, l) (smoothstep(n - RCP_16, n, l))

#define smoothScale(x, m) (pow(x, m) * (m))
#define smoothScale2(x, m) (pow(x, 1/(m)) * (m))

#define LUMINANCE_COEFFS_RGB vec3(0.2126, 0.7152, 0.0722)
#define LUMINANCE_COEFFS_RGB_INVERSE vec3(4.7037, 1.3982, 13.8504)
#define LUMINANCE_COEFFS_AP1 vec3(0.27222872, 0.67408177, 0.05368952)
#define LUMINANCE_COEFFS_AP1_INVERSE vec3(3.6734, 1.4835, 18.6256)


#define hand(h) ((h) < 0.558)
#define removeBorder(n, r) (((n) - 0.5) * (1 - (r)) + 0.5)
// use this for very simple gamma correction where accuracy doesn't matter (such as fog color)
#define gammaCorrection(x, y) pow(x, vec3(y))

// courtesy of https://haraldbrendel.com/colorspacecalculator.html

// no CAT
#define AP0_to_AP1 mat3(1.451439, -0.076554, 0.008316, -0.236511, 1.176230, -0.006032, -0.214929, -0.099676, 0.997716)
#define AP1_to_AP0 mat3(0.695452, 0.044795, -0.005526, 0.140679, 0.859671, 0.004025, 0.163869, 0.095534, 1.001501)
#define XYZ_to_AP1 mat3(1.641023, -0.663663, 0.011722, -0.324803, 1.615332, -0.008284, -0.236425, 0.016756, 0.988395)
#define AP1_to_XYZ mat3(0.662454, 0.134004, 0.156188, 0.272229, 0.674082, 0.053690, -0.005575, 0.004061, 1.010339)
// RGB refers to the sRGB/rec709 primaries
#define RGB_to_XYZ mat3(0.412391, 0.212639, 0.019331, 0.357584, 0.715169, 0.119195, 0.180481, 0.072192, 0.950532)
#define XYZ_to_RGB mat3(3.240970, -0.969244, 0.055630, -1.537383, 1.875968, -0.203977, -0.498611, 0.041555, 1.056972)

// with CAT02
#define RGB_to_AP1 mat3(0.613083, 0.070004, 0.020491, 0.341167, 0.918063, 0.106764, 0.045750, 0.011934, 0.872745)
#define AP1_to_RGB mat3(1.705080, -0.129701, -0.024166, -0.624233, 1.138469, -0.124614, -0.080846, -0.008768, 1.148781)

#define BT2020_to_AP1 mat3(0.974696, 0.001678, 0.004886, 0.021634, 0.997736, 0.021132, 0.003670, 0.000585, 0.973982)
#define AP1_to_BT2020 mat3(1.026019, -0.001723, -0.005110, -0.022166, 1.002319, -0.021636, -0.003853, -0.000596, 1.026745)

#define ADOBE_RGB_to_AP1 mat3(0.857308, 0.097890, 0.028653, 0.094978, 0.889664, 0.061135, 0.047714, 0.012446, 0.910211)
#define AP1_to_ADOBE_RGB mat3(1.182398, -0.129701, -0.028510, -0.122085, 1.138469, -0.072623, -0.060313, -0.008768, 1.101134)

#define DCI_P3_to_AP1 mat3(0.688416, 0.041535, 0.003733, 0.263399, 0.945713, 0.047492, 0.048185, 0.012752, 0.948775)
#define AP1_to_DCI_P3 mat3(1.477607, -0.064861, -0.002567, -0.408049, 1.076029, -0.052256, -0.069558, -0.011168, 1.054824)

#define DISPLAY_P3_to_AP1 mat3(0.735743, 0.046905, 0.003471, 0.214011, 0.939989, 0.038016, 0.050246, 0.013106, 0.958513)
#define AP1_to_DISPLAY_P3 mat3(1.379336, -0.068796, -0.002267, -0.311287, 1.079957, -0.041705, -0.068050, -0.011161, 1.043972)


// for aces_fitted
#define ACES_INPUT mat3(0.59719, 0.07600, 0.02840, 0.35458, 0.90834, 0.13383, 0.04823, 0.01566, 0.83777)
#define ACES_OUTPUT mat3(1.60475, -0.10208, -0.00327, -0.53108, 1.10813, -0.07276, -0.07367, -0.00605, 1.07602)
#define ACES_INPUT_INVERSE mat3(1.76474097, -0.67577768, -0.08896329, -0.14702785, 1.16025151, -0.01322366, -0.03633683, -0.16243644, 1.19877327)
#define ACES_OUTPUT_INVERSE mat3(0.64303825, 0.31118675, 0.04577546, 0.05926869, 0.93143649, 0.00929492, 0.0059619, 0.06392902, 0.93011838)

// for OKLab
#define OKLAB_M1 mat3(0.8189330101, 0.0329845436, 0.0482003018, 0.3618667424, 0.9293118715, 0.2643662691, -0.1288597137, 0.0361456387, 0.6338517070)
#define OKLAB_M2 mat3(0.2104542553, 1.9779984951, 0.0259040371, 0.7936177850, -2.4285922050, 0.7827717662, -0.0040720468, 0.4505937099, -0.8086757660)
#define OKLAB_M1_INVERSE mat3(1.22701385, -0.04058018, -0.07638128, -0.55779998, 1.11225687, -0.42148198, 0.28125615, -0.07167668, 1.58616322)
#define OKLAB_M2_INVERSE mat3(1.0, 1.00000001, 1.00000005, 0.39633779, -0.10556134, -0.08948418, 0.21580376, -0.06385417, -1.29148554)


// Settings
#define WAVING_ENABLED
#ifdef WAVING_ENABLED
#endif

// #define STILL_WIND
#ifdef STILL_WIND
#endif

#define LEAVE_WAVING_WAKE
#ifdef LEAVE_WAVING_WAKE
#endif

#define FLATTEN_GRASS
#ifdef FLATTEN_GRASS
#endif

// #define WAVING_FULL_BLOCKS_ENABLED
#ifdef WAVING_FULL_BLOCKS_ENABLED
#endif

#define WAVING_WATER_ENABLED
#ifdef WAVING_WATER_ENABLED
#endif

#define WAVING_RAIN_ENABLED
#ifdef WAVING_RAIN_ENABLED
#endif

#define WIND_STRENGTH_CONSTANT_USER 0.5 // [0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WIND_SPEED_CONSTANT_USER (-5.0)

#define WAVE_STRENGTH_CONSTANT_USER 1.0 // [0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6 1.8 2.0 2.4 2.8 3.2 3.6 4.0 4.5 5.0]

#define LIGHTNING_FLASHES 0.8 // [0.0 0.1 0.2 0.4 0.6 0.8 1.0]
#define NOISY_RAIN
#ifdef NOISY_RAIN
#endif
#define RAIN_AMOUNT_USER 0.6 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define RAIN_SCALE 3
#define RAIN_TRANSPARENCY 0.5 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define SNOW_OPACITY 1

#define CLOUD_EXTENSION 1.0 // [0.1 0.35 0.4 0.55 0.6 0.7 0.8 0.9 1.0 1.1 1.3]

#define BORDER_FOG
#ifdef BORDER_FOG
#endif

// #define SECONDARY_FOG
#ifdef SECONDARY_FOG
#endif


#define SECONDARY_FOG_START 0.3 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8]
#define SECONDARY_FOG_END 1.7 // [1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.2 2.4 2.6 2.8 3.0 3.5 4.0 4.5 5.0]

// #define FOG_ENABLED_USER
#ifdef FOG_ENABLED_USER
#endif

#define OVERWORLD_FOGGY_WEATHER
#ifdef OVERWORLD_FOGGY_WEATHER
#endif
// #define NETHER_FOGGY_WEATHER
#ifdef NETHER_FOGGY_WEATHER
#endif
// #define END_FOGGY_WEATHER
#ifdef END_FOGGY_WEATHER
#endif

#define EXPAND_SKY 0.1
#define HORIZON_AS_OCEAN
#ifdef HORIZON_AS_OCEAN
#endif

#define SPIDEREYES_MULT 1.0
#define ENCHANT_GLINT_MULT 3.0 // [1.0 2.0 3.0 4.0 5.0]

#define END_WARPING 0.0 // [0.0 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

#define PANORAMIC_WORLD 0 // [0 1 2]

// #define OUTLINE_THROUGH_BLOCKS
#ifdef OUTLINE_THROUGH_BLOCKS
#endif

#define OUTLINE_ALPHA 0.8 // [0.5 0.6 0.7 0.8 0.9 1.0]

#define OUTLINE_COLOR 0 // [-1 0 1 2 3 4]

#define FORCED_PERSPECTIVE_POWER 0.0 // [-0.5 -0.3 -0.2 -0.15 -0.1 -0.05 0.0 0.05 0.1 0.15 0.2 0.3 0.5]
#define FORCED_PERSPECTIVE_BIAS 1.0  // [0.35 0.46 0.59 0.77 1.0 1.3 1.69 2.2 2.86]
#define FORCED_PERSPECTIVE_SHAPE 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define VANILLA_COLORS 0.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define CUTOUT_ALIGN_STRENGTH 0.8 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]



// 0 is old lighting off, 1 is standard vanilla, 2 is custom shading, 3 is custom shading with PBR
#define SHADING_MODE 2 // [0 1 2 3]

#if SHADING_MODE != 3
    #define VANILLA_LIGHTING SHADING_MODE
#else
    #define VANILLA_LIGHTING 2
    #define USE_PBR
#endif

// try to infer material properties from block data/texture
#define AUTO_MAT
#ifdef AUTO_MAT
#endif

#define NORMAL_MAP_STRENGTH 10 // [0 1 2 3 4 5 6 7 8 9 10]

#define AO_MAP_STRENGTH 10 // [0 1 2 3 4 5 6 7 8 9 10]

#define DO_SUBSURFACE
#ifdef DO_SUBSURFACE
#endif

// #define COMPLEX_METALS
#ifdef COMPLEX_METALS
#endif

#define METALLIC_REDSTONE_BLOCK
#ifdef METALLIC_REDSTONE_BLOCK
#endif
// #define METALLIC_WAXED_COPPER
#ifdef METALLIC_WAXED_COPPER
#endif
#define METALLIC_NETHERITE_BLOCK
#ifdef METALLIC_NETHERITE_BLOCK
#endif


// 0: Schlick
#define FRESNEL_MODEL 0 // [0]
// 0: GGX 1: Cook-Torrance
#define GEOMETRY_MODEL 0 // [0 1]
// 0: GGX 1: Blinn-Phong
#define DISTRIBUTION_MODEL 0 // [0 1]

// #define RIMLIGHT_ENABLED
#ifdef RIMLIGHT_ENABLED
#endif
// #define RIMLIGHT_OUTLINE
#ifdef RIMLIGHT_OUTLINE
#endif
#define RIMLIGHT_DYNAMIC_RADIUS
#ifdef RIMLIGHT_DYNAMIC_RADIUS
#endif
#define RIMLIGHT_MULT 1.3 // [0.5 0.7 0.9 1.1 1.3 1.5 1.7 1.9 2.1 2.3 2.5]
#define RIMLIGHT_DIST 10.0 // [1.3 10.0]
#define RIMLIGHT_PIXEL_RADIUS 2 // [1 2 3 4 6 8]

// #define DYNAMIC_EXPOSURE_LIGHTING
#ifdef DYNAMIC_EXPOSURE_LIGHTING
#endif
#define SUN_TEMP 5777 // [1500 2000 2500 3000 3500 4000 4500 5000 5777 6000 7000 8000 9000 10000 11000 12000 13000 14000 15000]
#define TORCH_TEMP 5000 // [1500 2000 2500 3000 3500 4000 4500 5000 5500 6000 7000 8000 9000 10000 11000 12000 13000 14000 15000]

#define SKY_COLOR_BLEND 0.6 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define STAR_WEIGHTS 1.5 // [0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0]

#define SKY_BRIGHTNESS_USER 1.0 // [0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]
#define PLANET_BRIGHTNESS_USER 2.0

#define CONTRAST 0.0 //[-0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5]
#define EXPOSURE 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define SATURATION 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

#define POST_TEMP 6550 // [3500 4000 4500 5000 5500 6000 6550 8000 9000 10000 11000 12000 13000 14000 15000]

// -1 is auto, rest corresponds to _COLORSPACE defs
#define OUTPUT_COLORSPACE -1 // [-1 0 1 2 3 4 6 7 9 10 11 12]
// output mapping: 0:none 1:reinhard 2:Hable 3:ACES/UE4 4:ACES/approx 5:Custom (default)
#define TONEMAP_USER 5 // [5 -1 2 3 0 1]
#if TONEMAP_USER == -1
    #define USE_LUT
    #define TONEMAP LUT_TONEMAP
#else
    #define TONEMAP TONEMAP_USER
#endif

// #define USE_NIGHT_EFFECT
#ifdef USE_NIGHT_EFFECT
#endif
#define NIGHT_EFFECT_SATURATION 0.3 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define NIGHT_EFFECT_POINT 0.1 // [0.0625 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15]

// #define BOSS_BATTLE_COLORS
#ifdef BOSS_BATTLE_COLORS
#endif

#define TEXTURE_FILTERING
#ifdef TEXTURE_FILTERING
#endif

// #define TEXTURE_FILTER_EVERYTHING
#ifdef TEXTURE_FILTER_EVERYTHING
#endif

// 0: none 1:DITAA (Double-Image TAA) 2: full TAA
#define TAA_MODE 2 // [0 1 2]

#if TAA_MODE == 1
#endif

#if TAA_MODE != 0
    #define AA_ENABLED
#endif

#if TAA_MODE == 2
    #define TAA_ENABLED
    #define FULL_TAA_ENABLED

    #define TAA_CLOSEST_MOTION_VECTOR
    #define TAA_USE_BICUBIC
    // #define TAA_SHARP_ENABLED
    #define TAA_DO_CLIPPING
    // #define TAA_DO_CLIPPING_IN_Y_CO_CG
#endif

#if TAA_MODE == 1
    #define TAA_ENABLED
    #define DITAA_ENABLED

    #define TAA_DO_CLIPPING
    // #define TAA_CORNER_CLAMPING

    #define TAA_NO_CLIPPING_WHEN_STILL
#endif

#define TAA_HYBRID_TONEMAP
#ifdef TAA_HYBRID_TONEMAP
#endif

// not enabled because high levels of atmospheric fog
// (ex. underwater or foggy weather) cause artifacting
// #define SIMPLIFY_BICUBIC_SAMPLING
#ifdef SIMPLIFY_BICUBIC_SAMPLING
#endif

#define TAA_SHARP_WEIGHT 1.2
#define TAA_SHARP_PIXEL_THRESHOLD 0.3

// output mapping: 0:none 1:8bit
#define DITHERING_MODE 1 // [0 1]

// output mapping: 0:none 1:vanilla 2:SSAO
#define AO_MODE 1 // [0 1 2]

#define AO_SQUARED
#ifdef AO_SQUARED
#endif

#if AO_MODE == 2
    #define SSAO_ENABLED
#endif

#define AO_INTENSITY 1.8 // [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]
#define VANILLA_AO_INTENSITY (AO_INTENSITY * 0.5)

// #define NO_SHADING
#ifdef NO_SHADING
#endif

// #define CLOSE_FADE_OUT
#ifdef CLOSE_FADE_OUT
#endif

// #define CLOSE_FADE_OUT_FULL
#ifdef CLOSE_FADE_OUT_FULL
#endif

#define FADE_OUT_RADIUS 1.0 // [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

#define AO_RADIUS 1.2 // [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6]
#define TEMPORAL_UPDATE_SPEED_AO 0.0026 // [0.001 0.0026 0.0063 0.013 0.024 0.041 0.066 0.1]
#define AO_SAMPLES 9 // [1 2 4 6 9 12 16 20 25 30 36 42 49 56]

// #define SUBSURFACE_SCATTERING
#ifdef SUBSURFACE_SCATTERING
#endif

// Lower number = higher brightness
#define STREAMER_MODE 1 // [3 2 1 0]

#define SUN_LIGHT_MULT_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define SKY_LIGHT_MULT_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define SKY_LIGHT_MULT_OVERCAST_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define MOON_LIGHT_MULT_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define NIGHT_SKY_LIGHT_MULT_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define BLOCK_LIGHT_MULT_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

#define BLOCK_LIGHT_POWER 1

#define HDR_TEX_STANDARD 0 // [0 1 2]

// #define FAST_GI
#ifdef FAST_GI
#endif
#define FAST_GI_STRENGTH 1.5
#define FAST_GI_LOD_LEVEL 8

#define ATMOSPHERIC_FOG_USER
#ifdef ATMOSPHERIC_FOG_USER
#endif
#define ATMOSPHERIC_FOG_DENSITY 0.0015 // [0.0005 0.00075 0.001 0.0015 0.002 0.0035 0.005]

#define PUDDLE_STRENGTH 10 // [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]

// #define PUDDLE_WATER_FOG
#ifdef PUDDLE_WATER_FOG
#endif

#define PUDDLES_REFLECT_SKY
#ifdef PUDDLES_REFLECT_SKY
#endif

#define RAIN_FOG
#ifdef RAIN_FOG
#endif

#define WATER_FOG
#ifdef WATER_FOG
#endif

#define WATER_FOG_FROM_OUTSIDE
#ifdef WATER_FOG_FROM_OUTSIDE
#endif

// #define DISABLE_WATER
#ifdef DISABLE_WATER
#endif

#define WATER_STYLE 0 // [0 1]

#define NOISY_LAVA 1 // [0 1 2]

// 0: off 1: misregistration 2: blur
#define INVISIBILITY_DISTORTION 1 // [0 1 2]
#define INVISIBILITY_DISTORT_STRENGTH 0.005 // [0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.01 0.011 0.012 0.013 0.014 0.015 0.016 0.017 0.018 0.019 0.02]

// #define BRIGHT_NETHER
#ifdef BRIGHT_NETHER
#endif

// #define TEX_RENDER
#ifdef TEX_RENDER
#endif
#define TEX_RES 16 // [4 8 16 32 64 128 256 512 1024 2048 4096]

#define SHADOWS_ENABLED_USER
#ifdef SHADOWS_ENABLED_USER
#endif

#define GRASS_CASTS_SHADOWS
#ifdef GRASS_CASTS_SHADOWS
#endif

// #define VANILLA_SHADOWS
#ifdef VANILLA_SHADOWS
#endif

const int shadowMapResolution = 4096; // [512 1024 2048 4096 8192]
const float shadowDistance = 150.0; // [100.0 125.0 150.0 175.0 200.0 225.0 250.0 275.0 300.0]
const float entityShadowDistanceMul = 0.3; // [0.1 0.2 0.3 0.4]

#define SHADOW_DISTORTION 0.9 // [0.0 0.5 0.8 0.9 0.95 0.98]
// 0:off 1:2× 2:4×
#define SHADOW_SUPERSAMPLE 0 // [0 1 2]
#define SHADOW_AFFECTED_BY_LIGHTMAP
#ifdef SHADOW_AFFECTED_BY_LIGHTMAP
#endif

#define SHADOW_NORMAL_MIX_THRESHOLD 0.01

// 0:off 1:Percentage Closer 2:Variable-Penumbra Offbrand 3:Variable-Penumbra 4:Bilinear 5:Bilinear+Pixelated
#define SHADOW_FILTERING 5 // [0 1 4 5]
#define SHADOW_FILTERING_SAMPLES 5 // [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
#define SHADOW_FILTERING_RADIUS 0.1 // [0.025 0.05 0.075 0.1 0.125 0.15 0.175 0.2]

#define PIXELATED_SHADOWS_USER 0 // [0 8 16 32 64 128]

#if SHADOW_FILTERING == 5 && PIXELATED_SHADOWS == 0
    #define PIXELATED_SHADOWS TEX_RES
#else
    #define PIXELATED_SHADOWS PIXELATED_SHADOWS_USER
#endif

#define SHADOW_TRANSITION_MIXING 0 // [0 1]

#define SMOOTH_LAVA
#ifdef SMOOTH_LAVA
#endif


// #define USE_DOF
#ifdef USE_DOF
#endif


// #define DEBUG_VIEW
#ifdef DEBUG_VIEW
#endif
// #define SHADOW_DEBUG
#ifdef SHADOW_DEBUG
#endif
#define ISOLATE_RENDER_STAGE -1 // [-1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23]

#define END_SKY_RESOLUTION 128 // [32 64 128 256]



// "temporary" hardcoding

// use floats since they aren't capped at one (for easier color manipulation)
/*
const int colortex0Format = RGB16F;
const vec4 colortex0ClearColor = vec4(0.0, 0.0, 0.0, 0.0);

const int colortex1Format = RGBA16F;

const int colortex2Format = RGB8;

const int colortex3Format = RGB8_SNORM;
const bool colortex3Clear = false;

const int colortex4Format = RGB16F;
const bool colortex4Clear = false;

const int colortex5Format = RG16F;

const int shadowcolor1Format = R16F;
const bool shadowcolor1Clear = false;
*/

const bool noisetexNearest = false;

const bool generateShadowMipmap = false;
const bool generateShadowColorMipmap = false;

#if AO_MODE == 1
    const float ambientOcclusionLevel = 1.0;
#else
   const float ambientOcclusionLevel = 0.0;
#endif

const float centerDepthHalflife = 1.0;

#define USE_LIGHT_RADIUS_HACK

#if VANILLA_LIGHTING != 2
    const float sunPathRotation = 0.0;
#else
    const float sunPathRotation = -20.0;
#endif

const float shadowDistanceRenderMul = 1.0;
const int noiseTextureResolution = 512;
const float shadowIntervalSize = 8.0;

#define SHADOW_CUTOFF 0.76

#if SHADOW_SUPERSAMPLE != 0
    const bool shadowtex1Nearest = true;
    const bool shadowcolor1Nearest = true;
#endif

#if SHADOW_SUPERSAMPLE == 1
    #define SHADOW_RES_MULT 2.0
    #define SHADOW_RES_MULT_RCP 0.5
#elif SHADOW_SUPERSAMPLE == 2
    #define SHADOW_RES_MULT 4.0
    #define SHADOW_RES_MULT_RCP 0.25
#endif

#if VANILLA_LIGHTING == 2
    #if !defined DYNAMIC_EXPOSURE_LIGHTING
        #define SUN_LIGHT_MULT (15.7 * SUN_LIGHT_MULT_USER)
        #define SKY_LIGHT_MULT (2.0 * SKY_LIGHT_MULT_USER)
        #define SKY_LIGHT_MULT_OVERCAST (2.0 * SKY_LIGHT_MULT_OVERCAST_USER)
        #define MOON_LIGHT_MULT (2.2 * MOON_LIGHT_MULT_USER)
        #define NIGHT_SKY_LIGHT_MULT (1.1 * NIGHT_SKY_LIGHT_MULT_USER)
        #define BLOCK_LIGHT_MULT (15.7 * BLOCK_LIGHT_MULT_USER)
    #else
        #define SUN_LIGHT_MULT 11.100
        #define SKY_LIGHT_MULT 19.5
        #define SKY_LIGHT_MULT_OVERCAST 1.0
        #define MOON_LIGHT_MULT 0.0075
        #define NIGHT_SKY_LIGHT_MULT 0.001
        #define BLOCK_LIGHT_MULT 0.64
    #endif
#else
    #define SKY_LIGHT_MULT (3.0 * SKY_LIGHT_MULT_USER)
    #define BLOCK_LIGHT_MULT (3.0 * BLOCK_LIGHT_MULT_USER)

    #define SUN_LIGHT_MULT (4.0 * SUN_LIGHT_MULT_USER)

    #define SKY_LIGHT_MULT_OVERCAST (2.0 * SKY_LIGHT_MULT_OVERCAST_USER)
    #define MOON_LIGHT_MULT (0.7 * MOON_LIGHT_MULT_USER)
    #define NIGHT_SKY_LIGHT_MULT (0.6 * NIGHT_SKY_LIGHT_MULT_USER)
#endif

#define DEFAULT_EMISSIVE_STRENGTH BLOCK_LIGHT_MULT

#define VANILLA_LIGHTING_SKY_BLEED (SKY_LIGHT_MULT / SUN_LIGHT_MULT)

#define VANILLA_NATURAL_AMBIENT_LIGHT 0.141

// Removed from options intentionally, this is controlled through streamer mode option now
#define MIN_LIGHT_MULT_USER 5.0
#define AMBIENT_LIGHT_MULT_USER 1.0

#define EXPOSURE_WEIGHT 0.4

// measuring face of stone block
#if TONEMAP == 4 || TONEMAP == 5
    #if !defined DYNAMIC_EXPOSURE_LIGHTING
        #if STREAMER_MODE == 0 || STREAMER_MODE == -1
            #define MIN_LIGHT_MULT (MIN_LIGHT_MULT_USER * 0.25)
            #define AMBIENT_LIGHT_MULT (AMBIENT_LIGHT_MULT_USER * 0.55)
        #elif STREAMER_MODE == 1
            #define MIN_LIGHT_MULT (MIN_LIGHT_MULT_USER * 0.05)
            #define AMBIENT_LIGHT_MULT (AMBIENT_LIGHT_MULT_USER * 0.17)
        #elif STREAMER_MODE == 2
            #define MIN_LIGHT_MULT (MIN_LIGHT_MULT_USER * 0.01)
            #define AMBIENT_LIGHT_MULT (AMBIENT_LIGHT_MULT_USER * 0.10)
        #elif STREAMER_MODE == 3
            #define MIN_LIGHT_MULT 0.0
            #define AMBIENT_LIGHT_MULT 0.0
        #endif
    #else
        #define MIN_LIGHT_MULT (MIN_LIGHT_MULT_USER * 0.0001)
        #define AMBIENT_LIGHT_MULT (AMBIENT_LIGHT_MULT_USER * 0.001)
    #endif
#else
    #if !defined DYNAMIC_EXPOSURE_LIGHTING
        #if STREAMER_MODE == 0 || STREAMER_MODE == -1
            #define MIN_LIGHT_MULT (MIN_LIGHT_MULT_USER * 0.1)
            #define AMBIENT_LIGHT_MULT (AMBIENT_LIGHT_MULT_USER * 0.22)
        #elif STREAMER_MODE == 1
            #define MIN_LIGHT_MULT (MIN_LIGHT_MULT_USER * 0.02)
            #define AMBIENT_LIGHT_MULT (AMBIENT_LIGHT_MULT_USER * 0.068)
        #elif STREAMER_MODE == 2
            #define MIN_LIGHT_MULT (MIN_LIGHT_MULT_USER * 0.003)
            #define AMBIENT_LIGHT_MULT (AMBIENT_LIGHT_MULT_USER * 0.03)
        #elif STREAMER_MODE == 3
            #define MIN_LIGHT_MULT 0.0
            #define AMBIENT_LIGHT_MULT 0.0
        #endif
    #else
        #define MIN_LIGHT_MULT (MIN_LIGHT_MULT_USER * 0.00003)
        #define AMBIENT_LIGHT_MULT (AMBIENT_LIGHT_MULT_USER * 0.0003)
    #endif
#endif

#define TORCH_TINT (kelvinToColor(TORCH_TEMP))
#define TORCH_TINT_VANILLA (RGB_to_AP1 * vec3(1.0, 0.5, 0))


#define WIND_PERIOD_CONSTANT 0.3
#define WIND_STRENGTH_CONSTANT (0.3 * WIND_STRENGTH_CONSTANT_USER)
#define WIND_STRENGTH_CONSTANT_CALM 0.5
#define WIND_SPEED_CONSTANT (9000.0 * WIND_SPEED_CONSTANT_USER * WIND_STRENGTH_CONSTANT)

#define LIGHTNING_FLASH_TINT (vec3(0.5, 0.6, 1.0))
#define DIRECT_LIGHTNING_STRENGTH 200.0

#define RAIN_CONSTRAINT 0.12
#define RAIN_AMOUNT (0.6 - RAIN_AMOUNT_USER * 0.2 - RAIN_CONSTRAINT * 0.5)
#define RAIN_THICKNESS 1.4 // [0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6 1.8 2.0]

#if defined IS_IRIS
    #define THUNDER_THRESHOLD 0.6
#else
    #define THUNDER_THRESHOLD 1.0
#endif

#define THUNDER_BRIGHTNESS 0.6
#define RAINCLOUD_BRIGHTNESS 0.1

// DIM_NO_SKY is for dimensions which lack any fullscreen-covering gbuffers_skybasic/skytextured
// DIM_NO_HORIZON is for dimensions which don't have a defined horizon (and therefore look better with sky visible below said horizon)
// DIM_NO_SKYLIGHT is for dimensions which don't have values for skylight
// TODO: implement  Iris's hasSkyLight uniform in a way that doesn't break with Optifine
// DIM_USES_SKYBOX is for dimensions which use skytextured as their main sky layer (rather than just for solar bodies)

#if defined DIM_NETHER
    #define HAS_ATMOSPHERIC_FOG
    #define DIM_NO_RAIN
    #if defined NETHER_FOGGY_WEATHER
        #define DIM_HAS_FOGGY_WEATHER
    #endif

    #if defined BRIGHT_NETHER
        #define BASE_COLOR (vec3(2.0, 1.8, 1.6))
    #else
        #define BASE_COLOR (RGB_to_AP1 * vec3(1.0, 0.55, 0.4))
    #endif
    #define AMBIENT_COLOR (BASE_COLOR * 5.0)
    #define MIN_LIGHT_COLOR AMBIENT_COLOR
    #define CLOUD_COLOR AMBIENT_COLOR


    // The color is intentionally unconverted here to get a much more vibrant color than sRGB would allow
    // (that is the main benefit of an ACES workflow, after all)
    #define ATMOSPHERIC_FOG_COLOR (vec3(1.0, 0.09, 0.03))
    #define ATMOSPHERIC_FOG_MULTIPLIER 1.0

    #define SECONDARY_FOG_COLOR_MULTIPLIER 1.0

    #define WEATHER_FOG_MULTIPLIER 10.0
    #define RAINY_SKY_COLOR ATMOSPHERIC_FOG_COLOR

    #define NIGHT_SKY_EDGE_COLOR ATMOSPHERIC_FOG_COLOR
    #define NIGHT_SKY_TOP_COLOR ATMOSPHERIC_FOG_COLOR

    #define DAY_SKY_COLOR ATMOSPHERIC_FOG_COLOR
    #define NIGHT_SKY_COLOR ATMOSPHERIC_FOG_COLOR

    #define SKY_BRIGHTNESS (SKY_BRIGHTNESS_USER)
    
    #define PLANET_BRIGHTNESS (PLANET_BRIGHTNESS_USER)

    #define FAST_GI_EXPOSURE_CORRECT_GRAY 0.6
#elif defined DIM_END
    #define HAS_ATMOSPHERIC_FOG
    #define DIM_NO_RAIN
    #define DIM_NO_HORIZON
    #define DIM_USES_SKYBOX
    #define HAS_SKY
    #define DIM_NO_WIND
    #if defined END_FOGGY_WEATHER
        #define DIM_HAS_FOGGY_WEATHER
    #endif


    #define BASE_COLOR (RGB_to_AP1 * vec3(0.9, 0.7, 1.2))
    #define AMBIENT_COLOR (RGB_to_AP1 * vec3(0.9, 0.85, 1.1) * 10.0)
    #define MIN_LIGHT_COLOR AMBIENT_COLOR
    #define CLOUD_COLOR AMBIENT_COLOR

    #define SKY_BRIGHTNESS (SKY_BRIGHTNESS_USER * 10.2)
    #define SKY_ADDITIVE (BASE_COLOR * 0.002)
    
    #define PLANET_BRIGHTNESS (PLANET_BRIGHTNESS_USER)

    #define ATMOSPHERIC_FOG_COLOR ((vec3(0.7, 0.5, 1.2)) * 0.1)
    #define ATMOSPHERIC_FOG_MULTIPLIER 5.0

    #define SECONDARY_FOG_COLOR_MULTIPLIER 1.0

    #define WEATHER_FOG_MULTIPLIER 10.0
    #define RAINY_SKY_COLOR ATMOSPHERIC_FOG_COLOR

    #define NIGHT_SKY_EDGE_COLOR ATMOSPHERIC_FOG_COLOR
    #define NIGHT_SKY_TOP_COLOR ATMOSPHERIC_FOG_COLOR

    #define DAY_SKY_COLOR ATMOSPHERIC_FOG_COLOR
    #define NIGHT_SKY_COLOR ATMOSPHERIC_FOG_COLOR


    #define BOSS_BATTLE_SKY_MULT 0.7
    #define BOSS_BATTLE_ATMOSPHERIC_FOG_COLOR (BASE_COLOR * 0.1)

    #define FAST_GI_EXPOSURE_CORRECT_GRAY 0.5
#elif defined DIM_TWILIGHT
    #define HAS_ATMOSPHERIC_FOG
    #define ATMOSPHERIC_FOG_IN_SKY_ONLY
    #define WEATHER_FOG_IN_SKY_ONLY
    // #define HAS_SKY
    #define HAS_SKYLIGHT
    #if defined TWILIGHT_FOGGY_WEATHER
        #define DIM_HAS_FOGGY_WEATHER
    #endif

    #define BASE_COLOR (RGB_to_AP1 * vec3(1.0, 1.0, 1.0))
    #define AMBIENT_COLOR (BASE_COLOR * 1.0)
    #define MIN_LIGHT_COLOR (RGB_to_AP1 * vec3(0.8, 0.9, 1.0))
    #define CLOUD_COLOR (vec3(0.97, 0.98, 1.0) * 0.8)
    
    #define ATMOSPHERIC_FOG_COLOR (rec709ToACEScg(fogColor))
    #define ATMOSPHERIC_FOG_MULTIPLIER 0.35

    #define SECONDARY_FOG_COLOR_MULTIPLIER 2.0

    #define WEATHER_FOG_MULTIPLIER 10.0
    #define RAINY_SKY_COLOR (vec3(0.3, 0.305, 0.31) * 0.5)

    #define NIGHT_SKY_EDGE_COLOR (vec3(0.4, 0.6, 0.7) * 4.7)
    #define NIGHT_SKY_TOP_COLOR (vec3(0.05, 0.12, 0.4) * 3.0)

    #define DAY_SKY_COLOR ((RGB_to_AP1 * vec3(0.67, 0.83, 1.0)) * SKY_LIGHT_MULT)
    #define NIGHT_SKY_COLOR ((RGB_to_AP1 * vec3(0.4, 0.4, 1.0) * 4.0) * NIGHT_SKY_LIGHT_MULT)

    #define SKY_BRIGHTNESS (SKY_BRIGHTNESS_USER * 1.2)

    #define PLANET_BRIGHTNESS (PLANET_BRIGHTNESS_USER)

    #define FAST_GI_EXPOSURE_CORRECT_GRAY 0.3
#else
    #define HAS_ATMOSPHERIC_FOG
    #define ATMOSPHERIC_FOG_IN_SKY_ONLY
    #define WEATHER_FOG_IN_SKY_ONLY
    #define HAS_DAYNIGHT_CYCLE
    #define HAS_SKY
    #define HAS_SKYLIGHT
    #define HAS_SUN
    #define HAS_MOON
    #define HAS_SHADOWS
    #if defined OVERWORLD_FOGGY_WEATHER
        #define DIM_HAS_FOGGY_WEATHER
    #endif

    #define BASE_COLOR (RGB_to_AP1 * vec3(1.0, 1.0, 1.0))
    #define AMBIENT_COLOR (BASE_COLOR * 1.0)
    #define MIN_LIGHT_COLOR (RGB_to_AP1 * vec3(0.8, 0.9, 1.0))
    #define CLOUD_COLOR (vec3(0.97, 0.98, 1.0) * 0.8)
    
    #define ATMOSPHERIC_FOG_COLOR (rec709ToACEScg(fogColor))
    #define ATMOSPHERIC_FOG_MULTIPLIER 0.35

    #define SECONDARY_FOG_COLOR_MULTIPLIER 2.0

    #define WEATHER_FOG_MULTIPLIER 10.0
    #define RAINY_SKY_COLOR (vec3(0.3, 0.305, 0.31) * 0.5)

    #define NIGHT_SKY_EDGE_COLOR (vec3(0.0, 0.3, 0.7))
    #define NIGHT_SKY_TOP_COLOR (vec3(0.1, 0.1, 0.1))

    #define DAY_SKY_COLOR ((RGB_to_AP1 * vec3(0.67, 0.83, 1.0)) * SKY_LIGHT_MULT)
    #define NIGHT_SKY_COLOR ((RGB_to_AP1 * vec3(0.5, 0.6, 1.0)) * NIGHT_SKY_LIGHT_MULT)


    #define SKY_BRIGHTNESS (SKY_BRIGHTNESS_USER * 1.2)

    #define PLANET_BRIGHTNESS (PLANET_BRIGHTNESS_USER)

    #define FAST_GI_EXPOSURE_CORRECT_GRAY 0.3
#endif

#if defined ATMOSPHERIC_FOG_USER && defined HAS_ATMOSPHERIC_FOG
    #define ATMOSPHERIC_FOG
#endif
#if defined DIM_HAS_FOGGY_WEATHER && defined FOG_ENABLED_USER
    #define FOG_ENABLED
#endif
#if defined SHADOWS_ENABLED_USER && !defined VANILLA_SHADOWS && defined HAS_SUN && defined HAS_SKYLIGHT
    #define SHADOWS_ENABLED
#endif

#define ATMOSPHERIC_FOG_DENSITY_RAIN 0.005
#define ATMOSPHERIC_FOG_COLOR_RAIN (vec3(0.03, 0.1, 0.3))

#define ATMOSPHERIC_FOG_DENSITY_WATER 0.02
#define ATMOSPHERIC_FOG_COLOR_WATER (vec3(0.03, 0.2, 0.7))

#define FOG_DENSITY_ICE 0.1

#if defined RAIN_FOG
    #define RAIN_ADDER ATMOSPHERIC_FOG_DENSITY_RAIN * rainStrengthFiltered
#else
    #define RAIN_ADDER 0
#endif


#define ATMOSPHERIC_FOG_BRIGHTNESS_WATER (mix(0.2, skyTime * 0.4 + 0.6, EYE_BRIGHTNESS_SMOOTH_FLOAT_PROCESSED))

// #define OVERLAY_COLOR_WATER (vec3(0.7, 0.8, 1.0))
#define OVERLAY_COLOR_WATER (vec3(1.0))

#define ATMOSPHERIC_FOG_DENSITY_LAVA 4.0
#define ATMOSPHERIC_FOG_COLOR_LAVA (vec3(1.0, 0.3, 0.04))

#define ATMOSPHERIC_FOG_DENSITY_POWDER_SNOW 2.0
#define ATMOSPHERIC_FOG_COLOR_POWDER_SNOW (vec3(0.9, 1.0, 1.2))

#define NIGHT_VISION_AFFECTS_FOG_WATER 0.2
// TODO: feature request for fire resistance uniform (since lava fog is affected by that, not night vision in vanilla)
#define NIGHT_VISION_AFFECTS_FOG_LAVA 0.67
#define NIGHT_VISION_AFFECTS_FOG_POWDER_SNOW 0.0

#define ATMOSPHERIC_FOG_SPECTATOR_MULT_WATER 1.0
#define ATMOSPHERIC_FOG_SPECTATOR_MULT_LAVA 0.005
#define ATMOSPHERIC_FOG_SPECTATOR_MULT_POWDER_SNOW 0.01

// boss battle colors
#define OVERLAY_COLOR_ENDER_DRAGON (RGB_to_AP1 * vec3(0.82, 0.8, 0.85))
#define OVERLAY_SATURATION_ENDER_DRAGON 1.0
#define OVERLAY_COLOR_WITHER (RGB_to_AP1 * vec3(0.9, 0.7, 0.56))
#define OVERLAY_SATURATION_WITHER 0.7
#define OVERLAY_COLOR_RAID (RGB_to_AP1 * vec3(0.8, 1.0, 0.87))
#define OVERLAY_SATURATION_RAID 0.8

#define NIGHT_VISION_COLOR (RGB_to_AP1 * vec3(0.7, 0.8, 1.0))

#define DAY_SKY_COLOR_VANILLA ((RGB_to_AP1 * vec3(1)) * SKY_LIGHT_MULT)
#define NIGHT_SKY_COLOR_VANILLA ((RGB_to_AP1 * vec3(1)) * NIGHT_SKY_LIGHT_MULT)
#define SUN_COLOR ((kelvinToColor(SUN_TEMP)) * SUN_LIGHT_MULT)
#define MOON_COLOR ((RGB_to_AP1 * vec3(0.5, 0.66, 1.0)) * MOON_LIGHT_MULT)

#define NIGHT_EFFECT_HUE (RGB_to_AP1 * vec3(0.2, 0.6, 1.0))

#define COLORS_SATURATION_WEIGHTS normalize(vec3(COLORS_SATURATION_WEIGHTS_RED, COLORS_SATURATION_WEIGHTS_GREEN, COLORS_SATURATION_WEIGHTS_BLUE))

// #if TEX_RENDER_USER == 2
//     #define TEX_RENDER (1 - DEBUG_VIEW)
// #else 
//     #define TEX_RENDER TEX_RENDER_USER
// #endif

// inverse of TEX_RES
#define TEXELS_PER_BLOCK (1.0 / float(TEX_RES))