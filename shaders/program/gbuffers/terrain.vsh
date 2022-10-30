#include "/program/base/setup.vsh"

in vec4 mc_Entity;

#include "/lib/get_terrain_mask.glsl"

void main() {
   masks = vec4(0, 0, 0, 0);

   masks.b =
      float(mc_Entity.x == LIT)
   +  float(mc_Entity.x == LIT_CUTOUTS)
   +  float(mc_Entity.x == LIT_CUTOUTS_UPSIDE_DOWN)
   +  float(mc_Entity.x == LIT_PARTIAL)
   +  float(mc_Entity.x == LIT_PARTIAL_CUTOUTS)
   +  float(mc_Entity.x == LIT_PARTIAL_CUTOUTS_UPSIDE_DOWN);
   
   // 2 - normal, 1 - upside down, 3 - right side up
   masks.g = getCutoutMask(mc_Entity.x);

   #include "/program/base/body_basic.vsh"
}