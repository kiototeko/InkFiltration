//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: sort.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 07-May-2021 23:24:34
//

// Include Files
#include "sort.h"
#include "getPeaksA.h"
#include "getPeaksPre.h"
#include "rt_nonfinite.h"
#include "sortIdx.h"

// Type Definitions
struct emxArray_int32_T_90
{
  int data[90];
  int size[1];
};

// Function Definitions

//
// Arguments    : int x_data[]
//                const int x_size[1]
// Return Type  : void
//
void sort(int x_data[], const int x_size[1])
{
  int dim;
  int vstride;
  int vlen;
  int vwork_size[1];
  int k;
  int vwork_data[90];
  emxArray_int32_T_90 b_vwork_data;
  dim = 0;
  if (x_size[0] != 1) {
    dim = -1;
  }

  if (dim + 2 <= 1) {
    vstride = x_size[0];
  } else {
    vstride = 1;
  }

  vlen = vstride - 1;
  vwork_size[0] = vstride;
  vstride = 1;
  for (k = 0; k <= dim; k++) {
    vstride *= x_size[0];
  }

  for (dim = 0; dim < vstride; dim++) {
    for (k = 0; k <= vlen; k++) {
      vwork_data[k] = x_data[dim + k * vstride];
    }

    sortIdx(vwork_data, vwork_size, b_vwork_data.data, b_vwork_data.size);
    for (k = 0; k <= vlen; k++) {
      x_data[dim + k * vstride] = vwork_data[k];
    }
  }
}

//
// File trailer for sort.cpp
//
// [EOF]
//
