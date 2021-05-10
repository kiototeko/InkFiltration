//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: insertionsort.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 07-May-2021 23:24:34
//

// Include Files
#include "insertionsort.h"
#include "getPeaksA.h"
#include "getPeaksGlobal_data.h"
#include "getPeaksPre.h"
#include "rt_nonfinite.h"

// Function Definitions

//
// Arguments    : int x[34]
//                int xstart
//                int xend
// Return Type  : void
//
void insertionsort(int x[34], int xstart, int xend)
{
  int i;
  i = xstart + 1;
  for (int k = i; k <= xend; k++) {
    int xc;
    int idx;
    boolean_T exitg1;
    xc = x[k - 1];
    idx = k - 1;
    exitg1 = false;
    while ((!exitg1) && (idx >= xstart)) {
      int aj;
      int i1;
      int i2;
      aj = iv[x[idx - 1] - 1];
      i1 = iv[xc - 1];
      i2 = x[idx - 1];
      if ((i1 < aj) || ((i1 == aj) && (iv1[xc - 1] < iv1[i2 - 1]))) {
        x[idx] = i2;
        idx--;
      } else {
        exitg1 = true;
      }
    }

    x[idx] = xc;
  }
}

//
// File trailer for insertionsort.cpp
//
// [EOF]
//
