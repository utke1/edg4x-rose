/*
  Test vectorization for multi-dimensional array
*/
#include "rose_simd.h" 

int main()
{
  int i_nom_1_strip_13;
  int i_nom_1;
  float a[64][32][16];
  __SIMD (*a_SIMD)[32][16 / 4] = (__SIMD (*)[32][16 / 4])a;
  float b[32][16];
  __SIMD (*b_SIMD)[16 / 4] = (__SIMD (*)[16 / 4])b;
  float c[16];
  __SIMD *c_SIMD = (__SIMD *)c;
  __SIMD __constant0__ = _SIMD_splats_ps(5.f);
  __SIMD __constant1__ = _SIMD_splats_ps(2.f);
  __SIMD __constant2__ = _SIMD_splats_ps(4.f);
  for (int k = 0; k < 64; k++) {
    for (int j = 0; j < 32; j++) {
      
#pragma SIMD
      for (i_nom_1 = 0, i_nom_1_strip_13 = i_nom_1; i_nom_1 <= 15; (i_nom_1 += 4 , i_nom_1_strip_13 += 1)) {
        a_SIMD[k][j][i_nom_1_strip_13] = __constant0__;
        b_SIMD[j][i_nom_1_strip_13] = __constant1__;
        c_SIMD[i_nom_1_strip_13] = __constant2__;
      }
    }
  }
}
