#if defined USE_HELD_ITEM_ID
uniform int heldItemId;
#endif
#if defined USE_HELD_BLOCK_LIGHT_VALUE
uniform int heldBlockLightValue;
#endif
#if defined USE_HELD_ITEM_ID_2
uniform int heldItemId2;
#endif
#if defined USE_HELD_BLOCK_LIGHT_VALUE_2
uniform int heldBlockLightValue2;
#endif
#if defined USE_FOG_MODE
uniform int fogMode;
#endif
#if defined USE_FOG_START
uniform float fogStart;
#endif
#if defined USE_FOG_END
uniform float fogEnd;
#endif
#if defined USE_FOG_SHAPE
uniform int fogShape;
#endif
#if defined USE_FOG_DENSITY
uniform float fogDensity;
#endif
#if defined USE_FOG_COLOR
uniform vec3 fogColor;
#endif
#if defined USE_SKY_COLOR
uniform vec3 skyColor;
#endif
#if defined USE_WORLD_TIME
uniform int worldTime;
#endif
#if defined USE_WORLD_DAY
uniform int worldDay;
#endif
#if defined USE_MOON_PHASE
uniform int moonPhase;
#endif
#if defined USE_FRAME_COUNTER
uniform int frameCounter;
#endif
#if defined USE_FRAME_TIME
uniform float frameTime;
#endif
#if defined USE_FRAME_TIME_COUNTER
uniform float frameTimeCounter;
#endif
#if defined USE_SUN_ANGLE
uniform float sunAngle;
#endif
#if defined USE_SHADOW_ANGLE
uniform float shadowAngle;
#endif
#if defined USE_RAIN_STRENGTH
uniform float rainStrength;
#endif
#if defined USE_ASPECT_RATIO
uniform float aspectRatio;
#endif
#if defined USE_VIEW_WIDTH
uniform float viewWidth;
#endif
#if defined USE_VIEW_HEIGHT
uniform float viewHeight;
#endif
#if defined USE_NEAR
uniform float near;
#endif
#if defined USE_FAR
uniform float far;
#endif
#if defined USE_SUN_POSITION
uniform vec3 sunPosition;
#endif
#if defined USE_MOON_POSITION
uniform vec3 moonPosition;
#endif
#if defined USE_SHADOW_LIGHT_POSITION
uniform vec3 shadowLightPosition;
#endif
#if defined USE_UP_POSITION
uniform vec3 upPosition;
#endif
#if defined USE_CAMERA_POSITION
uniform vec3 cameraPosition;
#endif
#if defined USE_PREVIOUS_CAMERA_POSITION
uniform vec3 previousCameraPosition;
#endif

#if defined USE_GBUFFER_MODEL_VIEW
uniform mat4 gbufferModelView;
#endif

#if defined USE_GBUFFER_MODEL_VIEW_INVERSE
uniform mat4 gbufferModelViewInverse;
#endif

#if defined USE_GBUFFER_PREVIOUS_MODEL_VIEW
uniform mat4 gbufferPreviousModelView;
#endif

#if defined USE_GBUFFER_PROJECTION
uniform mat4 gbufferProjection;
#endif

#if defined USE_GBUFFER_PROJECTION_INVERSE
uniform mat4 gbufferProjectionInverse;
#endif

#if defined USE_GBUFFER_PREVIOUS_PROJECTION
uniform mat4 gbufferPreviousProjection;
#endif

#if defined USE_SHADOW_PROJECTION
uniform mat4 shadowProjection;
#endif

#if defined USE_SHADOW_PROJECTION_INVERSE
uniform mat4 shadowProjectionInverse;
#endif

#if defined USE_SHADOW_MODEL_VIEW
uniform mat4 shadowModelView;
#endif

#if defined USE_SHADOW_MODEL_VIEW_INVERSE
uniform mat4 shadowModelViewInverse;
#endif

#if defined USE_WETNESS
uniform float wetness;
#endif

#if defined USE_EYE_ALTITUDE
uniform float eyeAltitude;
#endif

#if defined USE_EYE_BRIGHTNESS
uniform ivec2 eyeBrightness;
#endif

#if defined USE_EYE_BRIGHTNESS_SMOOTH
uniform ivec2 eyeBrightnessSmooth;
#endif

#if defined USE_TERRAIN_TEXTURE_SIZE
uniform ivec2 terrainTextureSize;
#endif

#if defined USE_TERRAIN_ICON_SIZE
uniform int terrainIconSize;
#endif

#if defined USE_EYE_IN_WATER
uniform int isEyeInWater;
#endif

#if defined USE_NIGHT_VISION
uniform float nightVision;
#endif

#if defined USE_BLINDNESS
uniform float blindness;
#endif

#if defined USE_SCREEN_BRIGHTNESS
uniform float screenBrightness;
#endif

#if defined USE_HIDE_GUI
uniform int hideGUI;
#endif

#if defined USE_CENTER_DEPTH_SMOOTH
uniform float centerDepthSmooth;
#endif

#if defined USE_ATLAS_SIZE
uniform ivec2 atlasSize;
#endif

#if defined USE_SPRITE_BOUNDS
uniform vec4 spriteBounds;
#endif

#if defined USE_ENTITY_COLOR
uniform vec4 entityColor;
#endif

#if defined USE_ENTITY_ID
uniform int entityId;
#endif

#if defined USE_BLOCK_ENTITY_ID
uniform int blockEntityId;
#endif

#if defined USE_BLEND_FUNC
uniform ivec4 blendFunc;
#endif

#if defined USE_INSTANCE_ID
uniform int instanceId;
#endif

#if defined USE_PLAYER_MOOD
uniform float playerMood;
#endif

#if defined USE_RENDER_STAGE
uniform int renderStage;
#endif

#if defined USE_BOSS_BATTLE
uniform int bossBattle;
#endif

// 1.17+
#if defined USE_MODEL_VIEW_MATRIX
uniform mat4 modelViewMatrix;
#endif

#if defined USE_MODEL_VIEW_MATRIX_INVERSE
uniform mat4 modelViewMatrixInverse;
#endif

#if defined USE_PROJECTION_MATRIX
uniform mat4 projectionMatrix;
#endif

#if defined USE_PROJECTION_MATRIX_INVERSE
uniform mat4 projectionMatrixInverse;
#endif

#if defined USE_TEXTURE_MATRIX
uniform mat4 textureMatrix;
#endif

#if defined USE_NORMAL_MATRIX
uniform mat3 normalMatrix;
#endif

#if defined USE_CHUNK_OFFSET
uniform vec3 chunkOffset;
#endif

#if defined USE_ALPHA_TEST_REF
uniform float alphaTestRef;
#endif

// 1.19+
#if defined USE_DARKNESS_FACTOR
uniform float darknessFactor;
#endif

#if defined USE_DARKNESS_LIGHT_FACTOR
uniform float darknessLightFactor;
#endif
