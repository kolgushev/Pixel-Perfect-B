#include "/program/base/setup.fsh"

void main() {
   vec4 masks = vec4(0, 0, 0, 1);
   #if defined DIM_NETHER || defined DIM_END
      buffer4.x = 1;
   #endif
   
   #include "/program/base/body_basic.fsh"
}