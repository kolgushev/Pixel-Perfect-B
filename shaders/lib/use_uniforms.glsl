#if defined use_held_item_id
uniform int heldItemId;
#endif

#if defined use_held_block_light_value
uniform int heldBlockLightValue;
#endif

#if defined use_held_item_id_2
uniform int heldItemId2;
#endif

#if defined use_held_block_light_value_2
uniform int heldBlockLightValue2;
#endif

#if defined use_fog_mode
uniform int fogMode;
#endif

#if defined use_fog_start
uniform float fogStart;
#endif

#if defined use_fog_end
uniform float fogEnd;
#endif

#if defined use_fog_shape
uniform int fogShape;
#endif

#if defined use_fog_density
uniform float fogDensity;
#endif

#if defined use_fog_color
uniform vec3 fogColor;
#endif

#if defined use_sky_color
uniform vec3 skyColor;
#endif

#if defined use_world_time
uniform int worldTime;
#endif

#if defined use_world_day
uniform int worldDay;
#endif

#if defined use_moon_phase
uniform int moonPhase;
#endif

#if defined use_frame_counter
uniform int frameCounter;
#endif

#if defined use_frame_time
uniform float frameTime;
#endif

#if defined use_frame_time_counter
uniform float frameTimeCounter;
#endif

#if defined use_sun_angle
uniform float sunAngle;
#endif

#if defined use_shadow_angle
uniform float shadowAngle;
#endif

#if defined use_rain_strength
uniform float rainStrength;
#endif

#if defined use_aspect_ratio
uniform float aspectRatio;
#endif

#if defined use_view_width
uniform float viewWidth;
#endif

#if defined use_view_height
uniform float viewHeight;
#endif

#if defined use_near
uniform float near;
#endif

#if defined use_far
uniform float far;
#endif

#if defined use_sun_position
uniform vec3 sunPosition;
#endif

#if defined use_moon_position
uniform vec3 moonPosition;
#endif

#if defined use_shadow_light_position
uniform vec3 shadowLightPosition;
#endif

#if defined use_up_position
uniform vec3 upPosition;
#endif

#if defined use_camera_position
uniform vec3 cameraPosition;
#endif

#if defined use_previous_camera_position
uniform vec3 previousCameraPosition;
#endif

#if defined use_gbuffer_model_view
uniform mat4 gbufferModelView;
#endif

#if defined use_gbuffer_model_view_inverse
uniform mat4 gbufferModelViewInverse;
#endif

#if defined use_gbuffer_previous_model_view
uniform mat4 gbufferPreviousModelView;
#endif

#if defined use_gbuffer_projection
uniform mat4 gbufferProjection;
#endif

#if defined use_gbuffer_projection_inverse
uniform mat4 gbufferProjectionInverse;
#endif

#if defined use_gbuffer_previous_projection
uniform mat4 gbufferPreviousProjection;
#endif

#if defined use_shadow_projection
uniform mat4 shadowProjection;
#endif

#if defined use_shadow_projection_inverse
uniform mat4 shadowProjectionInverse;
#endif

#if defined use_shadow_model_view
uniform mat4 shadowModelView;
#endif

#if defined use_shadow_model_view_inverse
uniform mat4 shadowModelViewInverse;
#endif

#if defined use_wetness
uniform float wetness;
#endif

#if defined use_eye_altitude
uniform float eyeAltitude;
#endif

#if defined use_eye_brightness
uniform ivec2 eyeBrightness;
#endif

#if defined use_eye_brightness_smooth
uniform ivec2 eyeBrightnessSmooth;
#endif

#if defined use_terrain_texture_size
uniform ivec2 terrainTextureSize;
#endif

#if defined use_terrain_icon_size
uniform int terrainIconSize;
#endif

#if defined use_is_eye_in_water
uniform int isEyeInWater;
#endif

#if defined use_night_vision
uniform float nightVision;
#endif

#if defined use_blindness
uniform float blindness;
#endif

#if defined use_screen_brightness
uniform float screenBrightness;
#endif

#if defined use_hide_gui
uniform int hideGUI;
#endif

#if defined use_center_depth_smooth
uniform float centerDepthSmooth;
#endif

#if defined use_atlas_size
uniform ivec2 atlasSize;
#endif

#if defined use_sprite_bounds
uniform vec4 spriteBounds;
#endif

#if defined use_entity_color
uniform vec4 entityColor;
#endif

#if defined use_entity_id
uniform int entityId;
#endif

#if defined use_block_entity_id
uniform int blockEntityId;
#endif

#if defined use_blend_func
uniform ivec4 blendFunc;
#endif

#if defined use_instance_id
uniform int instanceId;
#endif

#if defined use_player_mood
uniform float playerMood;
#endif

#if defined use_render_stage
uniform int renderStage;
#endif

#if defined use_boss_battle
uniform int bossBattle;
#endif

// 1.17+
#if defined use_model_view_matrix
uniform mat4 modelViewMatrix;
#endif

#if defined use_model_view_matrix_inverse
uniform mat4 modelViewMatrixInverse;
#endif

#if defined use_projection_matrix
uniform mat4 projectionMatrix;
#endif

#if defined use_projection_matrix_inverse
uniform mat4 projectionMatrixInverse;
#endif

#if defined use_texture_matrix
uniform mat4 textureMatrix;
#endif

#if defined use_normal_matrix
uniform mat3 normalMatrix;
#endif

#if defined use_chunk_offset
uniform vec3 chunkOffset;
#endif

#if defined use_alpha_test_ref
uniform float alphaTestRef;
#endif

// 1.19+
#if defined use_darkness_factor
uniform float darknessFactor;
#endif

#if defined use_darkness_light_factor
uniform float darknessLightFactor;
#endif



// Iris-exclusive uniforms
	#if defined use_is_spectator
		#if defined IS_IRIS
			uniform bool isSpectator;
		#else
			const bool isSpectator = false;
		#endif
	#endif

	#if defined use_thunder_strength
		#if defined IS_IRIS
			uniform float thunderStrength;
		#else
			const float thunderStrength = 0;
		#endif
	#endif

// custom uniforms

#if defined use_blindness_smooth
uniform float blindnessSmooth;
#endif

#if defined use_camera_diff_smooth
	uniform vec3 cameraDiffSmooth;
#endif

#if defined use_invisibility
uniform float invisibility;
#endif

#if defined use_moon_brightness
uniform float moonBrightness;
#endif

#if defined use_is_lightning
uniform float isLightning;
#endif

#if defined use_rain_wind
uniform float rainWind;
#endif

#if defined use_rain_wind_sharp
uniform float rainWindSharp;
#endif

#if defined use_lightning_bolt_position
uniform vec4 lightningBoltPosition;
#endif

#if defined use_in_sky
uniform float inSky;
	#if defined HAS_SKYLIGHT
		float inSkyProcessed = inSky;
	#else
		float inSkyProcessed = 1;
	#endif
#endif

#if defined use_fog_weather
uniform float fogWeather;
#endif

#if defined use_fog_weather_sky
uniform float fogWeatherSky;
#endif

#if defined use_direct_light_mult
uniform float directLightMult;
#endif

#if defined use_eye_brightness_smooth_float
uniform float eyeBrightnessSmoothFloat;
	#if defined HAS_SKYLIGHT
		float eyeBrightnessSmoothFloatProcessed = eyeBrightnessSmoothFloat;
	#else
		float eyeBrightnessSmoothFloatProcessed = 1;
	#endif
#endif

#if defined use_sky_albedo
uniform vec3 skyAlbedo;
#endif

#if defined use_sky_time
	#if defined DIM_TWILIGHT
		const float skyTime = 0.1;
	#else
		uniform float skyTime;
	#endif
#endif


// samplers
#if defined use_texture
uniform sampler2D gtexture;
#endif

#if defined use_colortex0
uniform sampler2D colortex0;
#endif

#if defined use_colortex1
uniform sampler2D colortex1;
#endif

#if defined use_colortex2
uniform sampler2D colortex2;
#endif

#if defined use_colortex3
uniform sampler2D colortex3;
#endif

#if defined use_colortex4
uniform sampler2D colortex4;
#endif

#if defined use_colortex5
uniform sampler2D colortex5;
#endif

#if defined use_colortex6
uniform sampler2D colortex6;
#endif

#if defined use_colortex7
uniform sampler2D colortex7;
#endif

#if defined use_colortex8
uniform sampler2D colortex8;
#endif


#if defined use_colortex0_3d
uniform sampler3D colortex0;
#endif

#if defined use_colortex1_3d
uniform sampler3D colortex1;
#endif

#if defined use_colortex2_3d
uniform sampler3D colortex2;
#endif

#if defined use_colortex3_3d
uniform sampler3D colortex3;
#endif

#if defined use_colortex4_3d
uniform sampler3D colortex4;
#endif

#if defined use_colortex5_3d
uniform sampler3D colortex5;
#endif

#if defined use_colortex6_3d
uniform sampler3D colortex6;
#endif

#if defined use_colortex7_3d
uniform sampler3D colortex7;
#endif

#if defined use_colortex8_3d
uniform sampler3D colortex8;
#endif





#if defined use_shadowcolor0
uniform sampler2D shadowcolor0;
#endif

#if defined use_shadowcolor1
uniform sampler2D shadowcolor1;
#endif


#if defined use_shadowcolor0_3d
uniform sampler3D shadowcolor0;
#endif

#if defined use_shadowcolor1_3d
uniform sampler3D shadowcolor1;
#endif




#if defined use_shadowtex0
uniform sampler2D shadowtex0;
#endif

#if defined use_shadowtex1
uniform sampler2D shadowtex1;
#endif


#if defined use_shadowtex0_3d
uniform sampler3D shadowtex0;
#endif

#if defined use_shadowtex1_3d
uniform sampler3D shadowtex1;
#endif




#if defined use_depthtex0
uniform sampler2D depthtex0;
#endif

#if defined use_depthtex1
uniform sampler2D depthtex1;
#endif


#if defined use_depthtex0_3d
uniform sampler3D depthtex0;
#endif

#if defined use_depthtex1_3d
uniform sampler3D depthtex1;
#endif



#if defined use_noisetex
uniform sampler2D noisetex;
#endif

#if defined use_noisetex_3d
uniform sampler3D noisetex;
#endif