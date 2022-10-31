#include "/program/base/setup.fsh"

#if AO_MODE == 1
    const float ambientOcclusionLevel = 1.0;
#else
   const float ambientOcclusionLevel = 0;
#endif

void main() {
   #include "/program/base/body_basic.fsh"
}