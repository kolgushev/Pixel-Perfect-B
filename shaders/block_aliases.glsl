#define BLOCKS_WATER_AND_WAVY_AND_AUTOMAT_SHINY 1
#define BLOCKS_ICE_AND_AUTOMAT_SHINY 2
#define BLOCKS_LAVA_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING 3
#define BLOCKS_REDSTONE 4
#define BLOCKS_REDSTONE_AND_AUTOMAT_GLOWING 5
#define BLOCKS_NETHERITE_BLOCK 6
#define BLOCKS_CROSS_CUTOUTS 7
#define BLOCKS_CROSS_CUTOUTS_AND_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_SOMEWHAT_POROUS 8
#define BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING 9
#define BLOCKS_CROSS_CUTOUTS_UPSIDE_DOWN_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING 10
#define BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING 11
#define BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING 12
#define BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_AUTOMAT_TRANSLUCENT 13
#define BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT 14
#define BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_AUTOMAT_TRANSLUCENT 15
#define BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF 16
#define BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT 17
#define BLOCKS_CROSS_CUTOUTS_AND_WAVY 18
#define BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING_AND_WAVY_AND_AUTOMAT_GLOWING 19
#define BLOCKS_CROSS_CUTOUTS_UPSIDE_DOWN 20
#define BLOCKS_CROSS_CUTOUTS_UPSIDE_DOWN_AND_LIGHT_EMITTING 21
#define BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_VERY_POROUS 22
#define BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_VERY_POROUS 23
#define BLOCKS_LIGHT_EMITTING 24
#define BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_SOMEWHAT_POROUS 25
#define BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_MATTE 26
#define BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_METALLIC 27
#define BLOCKS_AUTOMAT_METALLIC 28
#define BLOCKS_LIGHT_EMITTING_AND_WAXED_UNOXIDIZED_COPPER_AND_AUTOMAT_GLOWING 29
#define BLOCKS_WAXED_UNOXIDIZED_COPPER 30
#define BLOCKS_WAVY_AND_AUTOMAT_TRANSLUCENT 31
#define BLOCKS_WAVY_AND_STIFF_AND_AUTOMAT_TRANSLUCENT 32
#define BLOCKS_WAVY 33
#define BLOCKS_WAVY_AND_STIFF 34
#define BLOCKS_WAVY_AND_WAVES_FROM_BOTTOM_AND_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_SOMEWHAT_POROUS 35
#define BLOCKS_WAVY_AND_WAVES_FROM_BOTTOM 36
#define BLOCKS_WAVY_AND_ON_WATER 37
#define BLOCKS_WAXED_UNOXIDIZED_COPPER_AND_AUTOMAT_SHINY 38
#define BLOCKS_AUTOMAT_GLOWING_AND_AUTOMAT_SOMEWHAT_POROUS 39
#define BLOCKS_AUTOMAT_MATTE 40
#define BLOCKS_AUTOMAT_MATTE_AND_AUTOMAT_VERY_POROUS 41
#define BLOCKS_AUTOMAT_MATTE_AND_AUTOMAT_SOMEWHAT_POROUS 42
#define BLOCKS_AUTOMAT_SHINY 43
#define BLOCKS_AUTOMAT_SHINY_AND_AUTOMAT_METALLIC 44
#define BLOCKS_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_VERY_POROUS 45
#define BLOCKS_AUTOMAT_SOMEWHAT_POROUS 46
#define BLOCKS_AUTOMAT_VERY_POROUS 47
#define isBlockWater(id) (id == BLOCKS_WATER_AND_WAVY_AND_AUTOMAT_SHINY)
#define isBlockWavy(id) (id == BLOCKS_WATER_AND_WAVY_AND_AUTOMAT_SHINY || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY || id == BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING_AND_WAVY_AND_AUTOMAT_GLOWING || id == BLOCKS_WAVY_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_WAVY_AND_STIFF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_WAVY || id == BLOCKS_WAVY_AND_STIFF || id == BLOCKS_WAVY_AND_WAVES_FROM_BOTTOM_AND_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_WAVY_AND_WAVES_FROM_BOTTOM || id == BLOCKS_WAVY_AND_ON_WATER)
#define isBlockAutomatShiny(id) (id == BLOCKS_WATER_AND_WAVY_AND_AUTOMAT_SHINY || id == BLOCKS_ICE_AND_AUTOMAT_SHINY || id == BLOCKS_WAXED_UNOXIDIZED_COPPER_AND_AUTOMAT_SHINY || id == BLOCKS_AUTOMAT_SHINY || id == BLOCKS_AUTOMAT_SHINY_AND_AUTOMAT_METALLIC)
#define isBlockIce(id) (id == BLOCKS_ICE_AND_AUTOMAT_SHINY)
#define isBlockLava(id) (id == BLOCKS_LAVA_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING)
#define isBlockLightEmitting(id) (id == BLOCKS_LAVA_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING || id == BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING || id == BLOCKS_CROSS_CUTOUTS_UPSIDE_DOWN_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING || id == BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING || id == BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING_AND_WAVY_AND_AUTOMAT_GLOWING || id == BLOCKS_CROSS_CUTOUTS_UPSIDE_DOWN_AND_LIGHT_EMITTING || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_VERY_POROUS || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_VERY_POROUS || id == BLOCKS_LIGHT_EMITTING || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_MATTE || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_METALLIC || id == BLOCKS_LIGHT_EMITTING_AND_WAXED_UNOXIDIZED_COPPER_AND_AUTOMAT_GLOWING)
#define isBlockAutomatGlowing(id) (id == BLOCKS_LAVA_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING || id == BLOCKS_REDSTONE_AND_AUTOMAT_GLOWING || id == BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING || id == BLOCKS_CROSS_CUTOUTS_UPSIDE_DOWN_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING || id == BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING_AND_WAVY_AND_AUTOMAT_GLOWING || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_VERY_POROUS || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_MATTE || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_METALLIC || id == BLOCKS_LIGHT_EMITTING_AND_WAXED_UNOXIDIZED_COPPER_AND_AUTOMAT_GLOWING || id == BLOCKS_AUTOMAT_GLOWING_AND_AUTOMAT_SOMEWHAT_POROUS)
#define isBlockRedstone(id) (id == BLOCKS_REDSTONE || id == BLOCKS_REDSTONE_AND_AUTOMAT_GLOWING)
#define isBlockNetheriteBlock(id) (id == BLOCKS_NETHERITE_BLOCK)
#define isBlockCrossCutouts(id) (id == BLOCKS_CROSS_CUTOUTS || id == BLOCKS_CROSS_CUTOUTS_AND_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING || id == BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY || id == BLOCKS_CROSS_CUTOUTS_AND_LIGHT_EMITTING_AND_WAVY_AND_AUTOMAT_GLOWING)
#define isBlockAutomatTranslucent(id) (id == BLOCKS_CROSS_CUTOUTS_AND_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_WAVY_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_WAVY_AND_STIFF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_WAVY_AND_WAVES_FROM_BOTTOM_AND_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_VERY_POROUS)
#define isBlockAutomatSomewhatPorous(id) (id == BLOCKS_CROSS_CUTOUTS_AND_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_WAVY_AND_WAVES_FROM_BOTTOM_AND_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_AUTOMAT_GLOWING_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_AUTOMAT_MATTE_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_AUTOMAT_SOMEWHAT_POROUS)
#define isBlockCrossCutoutsUpsideDown(id) (id == BLOCKS_CROSS_CUTOUTS_UPSIDE_DOWN_AND_LIGHT_EMITTING_AND_AUTOMAT_GLOWING || id == BLOCKS_CROSS_CUTOUTS_UPSIDE_DOWN || id == BLOCKS_CROSS_CUTOUTS_UPSIDE_DOWN_AND_LIGHT_EMITTING)
#define isBlockTopHalf(id) (id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT)
#define isBlockStiff(id) (id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF || id == BLOCKS_CROSS_CUTOUTS_AND_WAVY_AND_STIFF_AND_TOP_HALF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_WAVY_AND_STIFF_AND_AUTOMAT_TRANSLUCENT || id == BLOCKS_WAVY_AND_STIFF)
#define isBlockAutomatVeryPorous(id) (id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_VERY_POROUS || id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_VERY_POROUS || id == BLOCKS_AUTOMAT_MATTE_AND_AUTOMAT_VERY_POROUS || id == BLOCKS_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_VERY_POROUS || id == BLOCKS_AUTOMAT_VERY_POROUS)
#define isBlockAutomatMatte(id) (id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_MATTE || id == BLOCKS_AUTOMAT_MATTE || id == BLOCKS_AUTOMAT_MATTE_AND_AUTOMAT_VERY_POROUS || id == BLOCKS_AUTOMAT_MATTE_AND_AUTOMAT_SOMEWHAT_POROUS)
#define isBlockAutomatMetallic(id) (id == BLOCKS_LIGHT_EMITTING_AND_AUTOMAT_GLOWING_AND_AUTOMAT_METALLIC || id == BLOCKS_AUTOMAT_METALLIC || id == BLOCKS_AUTOMAT_SHINY_AND_AUTOMAT_METALLIC)
#define isBlockWaxedUnoxidizedCopper(id) (id == BLOCKS_LIGHT_EMITTING_AND_WAXED_UNOXIDIZED_COPPER_AND_AUTOMAT_GLOWING || id == BLOCKS_WAXED_UNOXIDIZED_COPPER || id == BLOCKS_WAXED_UNOXIDIZED_COPPER_AND_AUTOMAT_SHINY)
#define isBlockWavesFromBottom(id) (id == BLOCKS_WAVY_AND_WAVES_FROM_BOTTOM_AND_AUTOMAT_TRANSLUCENT_AND_AUTOMAT_SOMEWHAT_POROUS || id == BLOCKS_WAVY_AND_WAVES_FROM_BOTTOM)
#define isBlockOnWater(id) (id == BLOCKS_WAVY_AND_ON_WATER)