// All the uniforms

uniform float alphaTestRef;
uniform float aspectRatio;
uniform float blindness;
uniform float centerDepthSmooth;
uniform float darknessFactor;
uniform float darknessLightFactor;
uniform float eyeAltitude;
uniform float far;
uniform float fogDensity;
uniform float fogEnd;
uniform float fogStart;
uniform float frameTime;
uniform float frameTimeCounter;
uniform float near;
uniform float nightVision;
uniform float playerMood;
uniform float rainStrength;
uniform float screenBrightness;
uniform float shadowAngle;
uniform float sunAngle;
uniform float viewHeight;
uniform float viewWidth;
uniform float wetness;
uniform int blockEntityId;
uniform int bossBattle;
uniform int entityId;
uniform int fogMode;
uniform int fogShape;
uniform int frameCounter;
uniform int heldBlockLightValue2;
uniform int heldBlockLightValue;
uniform int heldItemId2;
uniform int heldItemId;
uniform int hideGUI;
uniform int instanceId;
uniform int isEyeInWater;
uniform int moonPhase;
uniform int renderStage;
uniform int terrainIconSize;
uniform int worldDay;
uniform int worldTime;
uniform ivec2 atlasSize;
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform ivec2 terrainTextureSize;
uniform ivec4 blendFunc;
uniform mat3 normalMatrix;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 modelViewMatrix;
uniform mat4 modelViewMatrixInverse;
uniform mat4 projectionMatrix;
uniform mat4 projectionMatrixInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;


uniform vec3 cameraPosition;
uniform vec3 chunkOffset;
uniform vec3 fogColor;
uniform vec3 moonPosition;
uniform vec3 previousCameraPosition;
uniform vec3 shadowLightPosition;
uniform vec3 skyColor;
uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform vec4 entityColor;
uniform vec4 spriteBounds;

uniform sampler2D composite;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux3;
uniform sampler2D gaux4;
uniform sampler2D gdepth;
uniform sampler2D gdepthtex;
uniform sampler2D gnormal;
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D shadow;
uniform sampler2D shadowcolor;
uniform sampler2D specular;
uniform sampler2D tex;
uniform sampler2D watershadow;


#if defined use_colortex0_3d
uniform sampler3D colortex0;
#else
uniform sampler2D colortex0;
#endif

#if defined use_colortex1_3d
uniform sampler3D colortex1;
#else
uniform sampler2D colortex1;
#endif

#if defined use_colortex2_3d
uniform sampler3D colortex2;
#else
uniform sampler2D colortex2;
#endif

#if defined use_colortex3_3d
uniform sampler3D colortex3;
#else
uniform sampler2D colortex3;
#endif

#if defined use_colortex4_3d
uniform sampler3D colortex4;
#else
uniform sampler2D colortex4;
#endif

#if defined use_colortex5_3d
uniform sampler3D colortex5;
#else
uniform sampler2D colortex5;
#endif

#if defined use_colortex6_3d
uniform sampler3D colortex6;
#else
uniform sampler2D colortex6;
#endif

#if defined use_colortex7_3d
uniform sampler3D colortex7;
#else
uniform sampler2D colortex7;
#endif

#if defined use_colortex8_3d
uniform sampler3D colortex8;
#else
uniform sampler2D colortex8;
#endif

#if defined use_colortex9_3d
uniform sampler3D colortex9;
#else
uniform sampler2D colortex9;
#endif

#if defined use_colortex10_3d
uniform sampler3D colortex10;
#else
uniform sampler2D colortex10;
#endif

#if defined use_colortex11_3d
uniform sampler3D colortex11;
#else
uniform sampler2D colortex11;
#endif

#if defined use_colortex12_3d
uniform sampler3D colortex12;
#else
uniform sampler2D colortex12;
#endif

#if defined use_colortex13_3d
uniform sampler3D colortex13;
#else
uniform sampler2D colortex13;
#endif

#if defined use_colortex14_3d
uniform sampler3D colortex14;
#else
uniform sampler2D colortex14;
#endif

#if defined use_colortex15_3d
uniform sampler3D colortex15;
#else
uniform sampler2D colortex15;
#endif


#if defined use_shadowcolor0_3d
uniform sampler3D shadowcolor0;
#else
uniform sampler2D shadowcolor0;
#endif

#if defined use_shadowcolor1_3d
uniform sampler3D shadowcolor1;
#else
uniform sampler2D shadowcolor1;
#endif

#if defined use_shadowtex0_3d
uniform sampler3D shadowtex0;
#else
uniform sampler2D shadowtex0;
#endif

#if defined use_shadowtex1_3d
uniform sampler3D shadowtex1;
#else
uniform sampler2D shadowtex1;
#endif

#if defined use_depthtex0_3d
uniform sampler3D depthtex0;
#else
uniform sampler2D depthtex0;
#endif

#if defined use_depthtex1_3d
uniform sampler3D depthtex1;
#else
uniform sampler2D depthtex1;
#endif

#if defined use_depthtex2_3d
uniform sampler3D depthtex2;
#else
uniform sampler2D depthtex2;
#endif

#define use_noisetex_3d
#if defined use_noisetex_3d
uniform sampler3D noisetex;
#else
uniform sampler2D noisetex;
#endif

// custom uniforms
uniform float blindnessSmooth;
uniform float directLightMult;
uniform float eyeBrightnessSmoothFloat;
uniform float fogWeather;
uniform float fogWeatherSky;
uniform float inSky;
uniform float invisibility;
uniform float isLightning;
uniform float moonBrightness;
uniform float rainWind;
uniform float rainWindSharp;
uniform float rainStrengthFiltered;
uniform float skyTime;
uniform float skyTimeMixing;
uniform vec3 cameraDiffSmooth;
uniform vec3 skyAlbedo;
uniform vec3 skyA;
uniform vec3 skyB;
uniform vec3 skyC;
uniform vec3 skyD;
uniform vec3 skyE;
uniform vec3 skyF;
uniform vec3 skyG;
uniform vec3 skyH;
uniform vec3 skyI;
uniform vec3 skyZ;

#if defined HAS_SKYLIGHT
	#define EYE_BRIGHTNESS_SMOOTH_FLOAT_PROCESSED eyeBrightnessSmoothFloat
	#define IN_SKY_PROCESSED inSky
#else
	#define EYE_BRIGHTNESS_SMOOTH_FLOAT_PROCESSED 1.0
	#define IN_SKY_PROCESSED 1.0
#endif


// Iris-exclusive uniforms
uniform int bedrockLevel;
uniform int heightLimit;
uniform int logicalHeightLimit;
uniform bool hasCeiling;
uniform bool hasSkyLight;
uniform float ambientLight;

uniform int currentColorSpace;
uniform float thunderStrength;
uniform float currentPlayerHealth;
uniform float maxPlayerHealth;
uniform float currentPlayerHunger;
uniform float maxPlayerHunger;
uniform float currentPlayerAir;
uniform float maxPlayerAir;
uniform bool firstPersonCamera;
uniform bool isSpectator;
uniform vec3 eyePosition;
uniform float cloudTime;
uniform vec4 lightningBoltPosition;