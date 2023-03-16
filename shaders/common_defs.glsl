#define defs

/*
NOTE: Any color values that aren't multiplied by a color trasform (eg. RGB_to_ACEScg)
    are expected to be in the ACEScg colorspace.
*/

// include defs from other files
#include "/LUTs/lut_meta.glsl"

// constants

#define EPSILON 0.001
#define E 2.7182818284
#define PI 3.1415926538

#define SQRT_2 1.4142135624
#define ISQRT_2 0.7071067812
#define SQRT_3 1.73205080757
#define ISQRT_3 0.57735026919
#define SQRT_5 2.2360679775
#define ISQRT_5 0.4472135955
#define RCP_3 0.33333333333
#define RCP_7 0.14285714285
#define RCP_8 0.75
#define RCP_16 0.0625
#define RCP_255 0.00392156862
#define RCP_256 0.00390625

// multiply glsl log by these to change the logarithm's base
// found with [1 / ln(<base>)] for [CHANGE_BASE_<base>]
#define CHANGE_BASE_10 0.434294481903
#define CHANGE_BASE_2 1.44269504089

#define GAMMA 2.2
#define RCP_GAMMA 0.45454545455

#define LIGHT_MATRIX mat4(vec4(0.00390625, 0.0, 0.0, 0.0), vec4(0.0, 0.00390625, 0.0, 0.0), vec4(0.0, 0.0, 0.00390625, 0.0), vec4(0.03125, 0.03125, 0.03125, 1.0))
#define NOISETEX_TILES_RES 512
#define NOISETEX_TILES_WIDTH 2

// utils
// normal pow (usually) takes 9 GPU cycles to compute, so we can redefine any pow ≤ 9 as multiplication for a speedup
// this is usually done automatically by the compiler, but these settings allow it to be enabled manually
// #define OPTIMIZE_POW
#define OPTIMIZE_POW2

// NOTE: enabling these settings may actually lead to a decrease in performance, since (n) is evaluted for each time it is multiplied

#ifdef OPTIMIZE_POW2
    #define pow2(n) ((n) * (n))
#else
    #define pow2(n) pow(n, 2)
#endif
#ifdef OPTIMIZE_POW
    #define pow3(n) ((n) * (n) * (n))
    #define pow4(n) ((n) * (n) * (n) * (n))
    #define pow5(n) ((n) * (n) * (n) * (n) * (n))
    #define pow6(n) ((n) * (n) * (n) * (n) * (n) * (n))
    #define pow7(n) ((n) * (n) * (n) * (n) * (n) * (n) * (n))
    #define pow8(n) ((n) * (n) * (n) * (n) * (n) * (n) * (n) * (n))
    #define pow9(n) ((n) * (n) * (n) * (n) * (n) * (n) * (n) * (n) * (n))
#else
    #define pow3(n) pow(n, 3)
    #define pow4(n) pow(n, 4)
    #define pow5(n) pow(n, 5)
    #define pow6(n) pow(n, 6)
    #define pow7(n) pow(n, 7)
    #define pow8(n) pow(n, 8)
    #define pow9(n) pow(n, 9)
#endif
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
#define opaque1(a) vec4(a, a, a, 1)
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

#define LUMINANCE_COEFFS vec3(0.2126, 0.7152, 0.0722)
#define LUMINANCE_COEFFS_INVERSE vec3(4.7037, 1.3982, 13.8504)

#define hand(h) ((h) < 0.557)
#define removeBorder(n, r) (((n) - 0.5) * (1 - (r)) + 0.5)
#define gammaCorrection(x, y) pow(x, vec3(y))

// TODO: Add this as a custom uniform
#define skyTime(t) (clamp(sin(2 * PI * float(t + 785) / 24000) + 0.5, 0, 1))



#define USE_ACES
#ifdef USE_ACES
#endif

// using cat02
#if defined USE_ACES
// \[ *(-?\d+\.\d+) *(-?\d+\.\d+) *(-?\d+\.\d+) *\]
// $1, $2, $3, 

    #define RGB_to_ACEScg mat3(0.6131178129, 0.3411819959, 0.0457873443, 0.0699340823, 0.9181030375, 0.0119327755, 0.0204629926, 0.1067686634, 0.8727159106)
    #define ACEScg_to_RGB mat3(1.7048873310, -0.6241572745, -0.0808867739, -0.1295209353, 1.1383993260, -0.0087792418, -0.0241270599, -0.1246206123, 1.1488221099)
    #define ACEScg_to_ACES2065_1 mat3(0.6954522414, 0.1406786965, 0.1638690622, 0.0447945634, 0.8596711184, 0.0955343182, -0.0055258826, 0.0040252103, 1.0015006723)
#else
    #define RGB_to_ACEScg transpose(mat3(1, 0, 0, 0, 1, 0, 0, 0, 1))
    #define ACEScg_to_RGB transpose(mat3(1, 0, 0, 0, 1, 0, 0, 0, 1))
    #define ACEScg_to_ACES2065_1 transpose(mat3(1, 0, 0, 0, 1, 0, 0, 0, 1))
#endif

// Used for hill ACES
#define ACES_INPUT mat3(0.59719, 0.35458, 0.04823, 0.07600, 0.90834, 0.01566, 0.02840, 0.13383, 0.83777)
#define ACES_OUTPUT mat3(1.60475, -0.53108, -0.07367, -0.10208, 1.10813, -0.00605, -0.00327, -0.07276,  1.07602)

// ACEScg_to_RGB transformed with ACES_INPUT/ACES_OUTPUT so we don't have to do two matrix operations (although it's probably optimized by the compiler anyway)
#define ACEScg_to_RRT_SAT mat3(0.968409, 0.0267469, 0.0046879, 0.00892041, 0.986953, 0.00422555, 0.00874694, 0.031994, 0.959333)
#define RRT_SAT_to_ACEScg mat3(0.945253, 0.05206, 0.002847, 0.0147852, 0.981904, 0.00326916, 0.0149253, 0.0469684, 0.938042)




// Settings
#define WAVING_ENABLED
#ifdef WAVING_ENABLED
#endif

#define NO_WAVING_FULL_BLOCKS
#ifdef NO_WAVING_FULL_BLOCKS
#endif

#define WIND_STRENGTH_CONSTANT_USER 0.5 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]
#define WIND_SPEED_CONSTANT_USER (-5.0)

#define LIGHTNING_FLASHES 0.8 // [0.0 0.1 0.2 0.4 0.6 0.8 1.0]
#define NOISY_RAIN
#ifdef NOISY_RAIN
#endif
#define RAIN_AMOUNT_USER 0.6 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define RAIN_SCALE 3
#define RAIN_TRANSPARENCY 0.5 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

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

#define SPIDEREYES_MULT 10.0

#define END_WARPING 0.0 // [0.0 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

// #define OUTLINE_THROUGH_BLOCKS
#ifdef OUTLINE_THROUGH_BLOCKS
#endif

#define OUTLINE_COLOR 0 // [0 1 2 3 4]

#define FORCED_PERSPECTIVE_POWER 0.0 // [-0.5 -0.3 -0.2 -0.15 -0.1 -0.05 0.0 0.05 0.1 0.15 0.2 0.3 0.5]
#define FORCED_PERSPECTIVE_BIAS 1.0  // [0.35 0.46 0.59 0.77 1.0 1.3 1.69 2.2 2.86]
#define FORCED_PERSPECTIVE_SHAPE 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

#define VANILLA_COLORS 0.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define CUTOUT_ALIGN_STRENGTH 0.8 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

// 0 is old lighting off, 1 is standard vanilla, 2 is custom shading
#define VANILLA_LIGHTING 2 // [0 1 2]

// #define DYNAMIC_EXPOSURE_LIGHTING
#ifdef DYNAMIC_EXPOSURE_LIGHTING
#endif
#define SUN_TEMP 5777 // [1500 2000 2500 3000 3500 4000 4500 5000 5777 6000 7000 8000 9000 10000 11000 12000 13000 14000 15000]
#define TORCH_TEMP 5000 // [1500 2000 2500 3000 3500 4000 4500 5000 5500 6000 7000 8000 9000 10000 11000 12000 13000 14000 15000]

#define SKY_COLOR_BLEND 0.6 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define STAR_WEIGHTS 1.5 // [0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0]

#define SKY_SATURATION 1.0 // [0.5 0.75 1.0 1.13 1.69 2.53 3.8 5.7]
#define SKY_BRIGHTNESS_USER 1.0 // [0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]
#define PLANET_BRIGHTNESS_USER 2.0

#define CONTRAST 0.0 //[-0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6]
#define EXPOSURE 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define POST_SATURATION 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

#define USE_LUT
#ifdef USE_LUT
#endif

#define POST_TEMP 6550 // [3500 4000 4500 5000 5500 6000 6550 8000 9000 10000 11000 12000 13000 14000 15000]

// output mapping: 0:sRGB 1:ACEScg(raw) 2:ACES2065-1
#define USER_OUTPUT_COLORSPACE 0 // [0 1 2]
// output mapping: 0:none 1:divide by 16 2:reinhard 3:Hable 4:ACES/UE4 (default)
#define USER_LMT_MODE 4 // [0 1 2 3 4]
#define USER_GAMMA_CORRECT
#ifdef USER_GAMMA_CORRECT
#endif

// #define USE_NIGHT_EFFECT
#ifdef USE_NIGHT_EFFECT
#endif
#define NIGHT_EFFECT_SATURATION 0.3 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define NIGHT_EFFECT_POINT 0.1 // [0.0625 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15]

// #define BOSS_BATTLE_COLORS
#ifdef BOSS_BATTLE_COLORS
#endif

// output mapping: 0:none 1:8bit
#define DITHERING_MODE 1 // [0 1]

// output mapping: 0:none 1:vanilla 2:SSAO
#define AO_MODE 1 // [0 1 2]

#if AO_MODE == 2
    #define SSAO_ENABLED
#endif

#define AO_INTENSITY 1.6 // [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]
#define VANILLA_AO_INTENSITY (AO_INTENSITY * 0.5)

#define AO_RADIUS 1.2 // [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6]
#define TEMPORAL_UPDATE_SPEED_AO 0.0026 // [0.001 0.0026 0.0063 0.013 0.024 0.041 0.066 0.1]
#define AO_SAMPLES 9 // [1 2 4 6 9 12 16 20 25 30 36 42 49 56]

// Lower number = higher brightness
#define STREAMER_MODE 1 // [3 2 1 0]

#define SUN_LIGHT_MULT_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define SKY_LIGHT_MULT_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define SKY_LIGHT_MULT_OVERCAST_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define MOON_LIGHT_MULT_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define NIGHT_SKY_LIGHT_MULT_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define BLOCK_LIGHT_MULT_USER 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

#define BLOCK_LIGHT_POWER 1

#define HDR_TEX_LIGHT_BRIGHTNESS
#ifdef HDR_TEX_LIGHT_BRIGHTNESS
#endif

#define ATMOSPHERIC_FOG_USER
#ifdef ATMOSPHERIC_FOG_USER
#endif
#define ATMOSPHERIC_FOG_DENSITY 0.0015 // [0.0005 0.00075 0.001 0.0015 0.002 0.0035 0.005]

#define WATER_FOG_FROM_OUTSIDE
#ifdef WATER_FOG_FROM_OUTSIDE
#endif

#define NOISY_LAVA 1 // [0 1 2]

// #define INVISIBILITY_DISTORTION
#ifdef INVISIBILITY_DISTORTION
#endif
#define INVISIBILITY_DISTORT_STRENGTH 0.005

// #define BRIGHT_NETHER
#ifdef BRIGHT_NETHER
#endif

// #define SHADOWS_ENABLED_USER
#ifdef SHADOWS_ENABLED_USER
#endif

const int shadowMapResolution = 4096; // [512 1024 2048 4096 8192]
const float shadowDistance = 200.0; // [100.0 125.0 150.0 175.0 200.0 225.0 250.0 275.0 300.0]

#define SHADOW_DISTORTION 0.9 // [0.0 0.5 0.8 0.9 0.95 0.98]
// 0:off 1:2× 2:4×
#define SHADOW_SUPERSAMPLE 0 // [0 1 2]
#define SHADOW_AFFECTED_BY_LIGHTMAP
#ifdef SHADOW_AFFECTED_BY_LIGHTMAP
#endif

// 0:off 1:Percentage Closer 2:Variable-Penumbra Offbrand 3:Variable-Penumbra
#define SHADOW_FILTERING 1 // [0 1 2 3]
#define SHADOW_FILTERING_SAMPLES 5 // [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
#define SHADOW_FILTERING_RADIUS 0.1 // [0.025 0.05 0.075 0.1 0.125 0.15 0.175 0.2]

#define PIXELATED_SHADOWS 0 // [0 8 16 32 64 128]
#ifdef PIXELATED_SHADOWS
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
// #define TEX_RENDER
#ifdef TEX_RENDER
#endif
#define TEX_RES 0.0625 // [0.25 0.125 0.0625 0.03125 0.015625 0.0078125 0.00390625 0.001953125 0.0009765625]

#define END_SKY_RESOLUTION 128 // [32 64 128 256]



// "temporary" hardcoding
const bool noisetexNearest = false;

#if VANILLA_LIGHTING != 2
    const float sunPathRotation = 0.0;
#else
    const float sunPathRotation = -20.0;
#endif

const float shadowDistanceRenderMul = 1.0;
const int noiseTextureResolution = 512;
const float shadowIntervalSize = 8.0;

#define SHADOW_CUTOFF 0.76

#if defined SHADOWS_ENABLED_USER && defined DIM_OVERWORLD
    #define SHADOWS_ENABLED
#endif

#if SHADOW_SUPERSAMPLE != 0
    const bool shadowtex1Nearest = true;
    const bool shadowcolor1Nearest = true;
#endif

#if SHADOW_SUPERSAMPLE == 1
    #define SHADOW_RES_MULT 2.0
    #define SHADOW_RES_MULT_RCP 0.5
    vec2 superSampleOffsets[4] = vec2[4](
        vec2(-0.5, -0.5),
        vec2(-0.5, 0.5),
        vec2(0.5, -0.5),
        vec2(0.5, 0.5)
    );
#elif SHADOW_SUPERSAMPLE == 2
    #define SHADOW_RES_MULT 4.0
    #define SHADOW_RES_MULT_RCP 0.25
    vec2 superSampleOffsets[16] = vec2[16](
        vec2(-0.25, -0.25),
        vec2(0.75, 0.75),
        vec2(-0.75, 0.75),
        vec2(0.75, -0.75),
        vec2(-0.75, -0.75),
        vec2(0.75, -0.25),
        vec2(-0.25, 0.25),
        vec2(0.25, -0.75),
        vec2(-0.25, 0.75),
        vec2(0.25, 0.25),
        vec2(-0.75, -0.25),
        vec2(0.75, 0.25),
        vec2(-0.25, -0.75),
        vec2(0.25, 0.75),
        vec2(-0.75, 0.25),
        vec2(0.25, -0.25)
    );
#endif

#if VANILLA_LIGHTING == 2
    #ifndef DYNAMIC_EXPOSURE_LIGHTING
        #define SUN_LIGHT_MULT (5.0 * SUN_LIGHT_MULT_USER)
        #define SKY_LIGHT_MULT (4.0 * SKY_LIGHT_MULT_USER)
        #define SKY_LIGHT_MULT_OVERCAST (2.0 * SKY_LIGHT_MULT_OVERCAST_USER)
        #define MOON_LIGHT_MULT (0.7 * MOON_LIGHT_MULT_USER)
        #define NIGHT_SKY_LIGHT_MULT (0.6 * NIGHT_SKY_LIGHT_MULT_USER)
        #define BLOCK_LIGHT_MULT (5.0 * BLOCK_LIGHT_MULT_USER)
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

#define VANILLA_LIGHTING_SKY_BLEED (SKY_LIGHT_MULT / SUN_LIGHT_MULT)

#define VANILLA_NATURAL_AMBIENT_LIGHT 0.141

// Removed from options intentionally, this is controlled through streamer mode option now
#define MIN_LIGHT_MULT_USER 1.0 // [0.01 0.026 0.05 0.07 0.13 0.24 0.41 0.66 1.0]
#define AMBIENT_LIGHT_MULT_USER 1.0 // [0.01 0.026 0.05 0.07 0.13 0.24 0.41 0.66 1.0]

#define EXPOSURE_BIAS 0.5

#if defined USE_LUT
    #if defined LUT_OVERRIDE_GAMMA_CORRECT && defined LUT_GAMMA_CORRECT
        #define GAMMA_CORRECT
    #elif !defined LUT_OVERRIDE_GAMMA_CORRECT && defined USER_GAMMA_CORRECT
        #define GAMMA_CORRECT
    #endif
    
    #ifdef LUT_OUTPUT_COLORSPACE
        #define OUTPUT_COLORSPACE LUT_OUTPUT_COLORSPACE
    #else
        #define OUTPUT_COLORSPACE USER_OUTPUT_COLORSPACE
    #endif
    #ifdef LUT_LMT_MODE
        #define LMT_MODE LUT_LMT_MODE
    #else
        #define LMT_MODE USER_LMT_MODE
    #endif

#else
    #ifdef USER_GAMMA_CORRECT
        #define GAMMA_CORRECT
    #endif
    
    #define OUTPUT_COLORSPACE USER_OUTPUT_COLORSPACE
    #define LMT_MODE USER_LMT_MODE
#endif

// measuring face of stone block
#if LMT_MODE == 4
    #if !defined DYNAMIC_EXPOSURE_LIGHTING
        #if STREAMER_MODE == 0 || STREAMER_MODE == -1
            #define MIN_LIGHT_MULT (MIN_LIGHT_MULT_USER * 0.4)
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
            #define MIN_LIGHT_MULT (MIN_LIGHT_MULT_USER * 0.16)
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

#define TORCH_TINT (kelvinToRGB(TORCH_TEMP))
#define TORCH_TINT_VANILLA (vec3(1.0, 0.5, 0) * RGB_to_ACEScg)


#define WIND_PERIOD_CONSTANT 0.3
#define WIND_STRENGTH_CONSTANT (0.3 * WIND_STRENGTH_CONSTANT_USER)
#define WIND_SPEED_CONSTANT (9000.0 * WIND_SPEED_CONSTANT_USER * WIND_STRENGTH_CONSTANT)

#define LIGHTNING_FLASH_TINT (vec3(0.5, 0.6, 1.0))

#define RAIN_CONSTRAINT 0.12
#define RAIN_AMOUNT (0.6 - RAIN_AMOUNT_USER * 0.2 - RAIN_CONSTRAINT * 0.5)

// DIM_NO_SKY is for dimensions which lack any fullscreen-covering gbuffers_skybasic/skytextured
// DIM_NO_HORIZON is for dimensions which don't have a defined horizon (and therefore look better with sky visible below said horizon)
// DIM_NO_SKYLIGHT is for dimensions which don't have values for skylight
// DIM_USES_SKYBOX is for dimensions which use skytextured as their main sky layer (rather than just for solar bodies)

#if defined DIM_NETHER
    #define HAS_ATMOSPHERIC_FOG
    #define DIM_NO_RAIN
    #define DIM_NO_SKY
    #define DIM_NO_SKYLIGHT
    #if defined NETHER_FOGGY_WEATHER
        #define DIM_HAS_FOGGY_WEATHER
    #endif

    #if defined BRIGHT_NETHER
        #define BASE_COLOR (vec3(2.0, 1.8, 1.6))
    #else
        #define BASE_COLOR (vec3(1.0, 0.55, 0.4) * RGB_to_ACEScg)
    #endif
    #define AMBIENT_COLOR (BASE_COLOR * 5.0)
    #define MIN_LIGHT_COLOR AMBIENT_COLOR
    // The color is intentionally unconverted here to get a much more vibrant color than sRGB would allow
    // (that is the main benefit of an ACES workflow, after all)
    #define ATMOSPHERIC_FOG_COLOR (vec3(1.0, 0.09, 0.03))
    // #define ATMOSPHERIC_FOG_COLOR (vec3(0.04, 0.1, 1.0))

    #define ATMOSPHERIC_FOG_MULTIPLIER 1.0

    #define WEATHER_FOG_MULTIPLIER 10.0

    #define SKY_BRIGHTNESS (SKY_BRIGHTNESS_USER)
    
    #define PLANET_BRIGHTNESS (PLANET_BRIGHTNESS_USER)
#elif defined DIM_END
    #define HAS_ATMOSPHERIC_FOG
    #define DIM_NO_RAIN
    #define DIM_NO_HORIZON
    #define DIM_USES_SKYBOX
    #define DIM_NO_SKYLIGHT
    #define DIM_NO_WIND
    #if defined END_FOGGY_WEATHER
        #define DIM_HAS_FOGGY_WEATHER
    #endif


    #define BASE_COLOR (vec3(0.9, 0.7, 1.2) * RGB_to_ACEScg)
    #define AMBIENT_COLOR (vec3(0.9, 0.85, 1.1) * RGB_to_ACEScg * 10.0)
    #define MIN_LIGHT_COLOR AMBIENT_COLOR

    #define SKY_BRIGHTNESS (SKY_BRIGHTNESS_USER * 10.2)
    #define SKY_ADDITIVE (BASE_COLOR * 0.002)
    
    #define PLANET_BRIGHTNESS (PLANET_BRIGHTNESS_USER)

    #define ATMOSPHERIC_FOG_COLOR ((vec3(0.7, 0.5, 1.2)) * 0.4)
    #define ATMOSPHERIC_FOG_MULTIPLIER 5.0

    #define WEATHER_FOG_MULTIPLIER 10.0

    #define BOSS_BATTLE_SKY_MULT 0.7
    #define BOSS_BATTLE_ATMOSPHERIC_FOG_COLOR (BASE_COLOR * 0.1)
#else
    #define HAS_ATMOSPHERIC_FOG
    #define ATMOSPHERIC_FOG_IN_SKY_ONLY
    #define WEATHER_FOG_IN_SKY_ONLY
    #define DIM_HAS_DAYNIGHT_CYCLE
    #if defined OVERWORLD_FOGGY_WEATHER
        #define DIM_HAS_FOGGY_WEATHER
    #endif

    #define BASE_COLOR (vec3(1.0, 1.0, 1.0) * RGB_to_ACEScg)
    #define AMBIENT_COLOR (BASE_COLOR * 1.0)
    #define MIN_LIGHT_COLOR (vec3(0.8, 0.9, 1.0) * RGB_to_ACEScg)
    
    #define ATMOSPHERIC_FOG_COLOR (gammaCorrection(fogColor, GAMMA) * RGB_to_ACEScg)
    #define ATMOSPHERIC_FOG_MULTIPLIER 0.5

    #define WEATHER_FOG_MULTIPLIER 10.0

    #define SKY_BRIGHTNESS (SKY_BRIGHTNESS_USER * 1.2)

    #define PLANET_BRIGHTNESS (PLANET_BRIGHTNESS_USER)
#endif
#if defined ATMOSPHERIC_FOG_USER && defined HAS_ATMOSPHERIC_FOG
    #define ATMOSPHERIC_FOG
#endif
#if defined DIM_HAS_FOGGY_WEATHER && defined FOG_ENABLED_USER
    #define FOG_ENABLED
#endif


#define ATMOSPHERIC_FOG_DENSITY_WATER 0.02
#define ATMOSPHERIC_FOG_COLOR_WATER (vec3(0.03, 0.2, 0.7))
#define OVERLAY_COLOR_WATER (vec3(0.7, 0.8, 1.0))

#define ATMOSPHERIC_FOG_DENSITY_LAVA 4.0
#define ATMOSPHERIC_FOG_COLOR_LAVA (vec3(1.0, 0.3, 0.04))

#define ATMOSPHERIC_FOG_DENSITY_POWDER_SNOW 2.0
#define ATMOSPHERIC_FOG_COLOR_POWDER_SNOW (vec3(0.9, 1.0, 1.2))

#define NIGHT_VISION_AFFECTS_FOG_WATER 0.2
// TODO: feature request for fire resistance uniform (since lava fog is affected by that, not night vision in vanilla)
#define NIGHT_VISION_AFFECTS_FOG_LAVA 0.67
#define NIGHT_VISION_AFFECTS_FOG_POWDER_SNOW 0.0

// boss battle colors
#define OVERLAY_COLOR_ENDER_DRAGON (vec3(0.82, 0.8, 0.85) * RGB_to_ACEScg)
#define OVERLAY_SATURATION_ENDER_DRAGON 1.0
#define OVERLAY_COLOR_WITHER (vec3(0.9, 0.7, 0.56) * RGB_to_ACEScg)
#define OVERLAY_SATURATION_WITHER 0.7
#define OVERLAY_COLOR_RAID (vec3(0.8, 1.0, 0.87) * RGB_to_ACEScg)
#define OVERLAY_SATURATION_RAID 0.8

#define NIGHT_VISION_COLOR ((vec3(0.7, 0.8, 1.0) * RGB_to_ACEScg))

#define DAY_SKY_COLOR ((vec3(0.67, 0.83, 1.0) * RGB_to_ACEScg) * SKY_LIGHT_MULT)
#define NIGHT_SKY_COLOR ((vec3(0.5, 0.6, 1.0) * RGB_to_ACEScg) * NIGHT_SKY_LIGHT_MULT)
// #define NIGHT_SKY_COLOR ((vec3(1, 0.98, 0.95) * RGB_to_ACEScg) * NIGHT_SKY_LIGHT_MULT)
#define DAY_SKY_COLOR_VANILLA ((vec3(1) * RGB_to_ACEScg) * SKY_LIGHT_MULT)
#define NIGHT_SKY_COLOR_VANILLA ((vec3(1) * RGB_to_ACEScg) * NIGHT_SKY_LIGHT_MULT)
#define SUN_COLOR ((kelvinToRGB(SUN_TEMP)) * SUN_LIGHT_MULT)
#define MOON_COLOR ((vec3(0.5, 0.66, 1.0) * RGB_to_ACEScg) * MOON_LIGHT_MULT)
// #define MOON_COLOR ((vec3(0.95, 0.99, 1) * RGB_to_ACEScg) * MOON_LIGHT_MULT)

#define NIGHT_EFFECT_HUE (vec3(0.2, 0.6, 1.0) * RGB_to_ACEScg)

#define COLORS_SATURATION_WEIGHTS normalize(vec3(COLORS_SATURATION_WEIGHTS_RED, COLORS_SATURATION_WEIGHTS_GREEN, COLORS_SATURATION_WEIGHTS_BLUE))

// #if TEX_RENDER_USER == 2
//     #define TEX_RENDER (1 - DEBUG_VIEW)
// #else 
//     #define TEX_RENDER TEX_RENDER_USER
// #endif

// inverse of TEX_RES
#define TEXELS_PER_BLOCK (1 / TEX_RES)


// optifine setup
#include "/optifine_setup.glsl"
