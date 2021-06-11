//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: filter.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 07-May-2021 23:24:34
//

// Include Files
#include "filter.h"
#include "getPeaksA.h"
#include "getPeaksPre.h"
#include "rt_nonfinite.h"
#include <cstring>

// Function Definitions

//
// Arguments    : double b_data[]
//                double a_data[]
//                const double x[36]
//                const double zi_data[]
//                double y[36]
// Return Type  : void
//
void b_filter(double b_data[], double a_data[], const double x[36], const double
              zi_data[], double y[36])
{
  double a1;
  int k;
  a1 = a_data[0];
  if ((!rtIsInf(a_data[0])) && (!rtIsNaN(a_data[0])) && (!(a_data[0] == 0.0)) &&
      (a_data[0] != 1.0)) {
    for (k = 0; k < 13; k++) {
      b_data[k] /= a1;
    }

    for (k = 0; k < 12; k++) {
      a_data[k + 1] /= a1;
    }

    a_data[0] = 1.0;
  }

  std::memcpy(&y[0], &zi_data[0], 12U * sizeof(double));
  std::memset(&y[12], 0, 24U * sizeof(double));
  for (k = 0; k < 36; k++) {
    int naxpy;
    int j;
    int y_tmp;
    if (36 - k < 13) {
      naxpy = 35 - k;
    } else {
      naxpy = 12;
    }

    for (j = 0; j <= naxpy; j++) {
      y_tmp = k + j;
      y[y_tmp] += x[k] * b_data[j];
    }

    if (35 - k < 12) {
      naxpy = 34 - k;
    } else {
      naxpy = 11;
    }

    a1 = -y[k];
    for (j = 0; j <= naxpy; j++) {
      y_tmp = (k + j) + 1;
      y[y_tmp] += a1 * a_data[j + 1];
    }
  }
}

//
// Arguments    : double b_data[]
//                double a_data[]
//                const double x[36]
//                const double zi_data[]
//                double y[36]
//                double zf_data[]
//                int zf_size[1]
// Return Type  : void
//
void filter(double b_data[], double a_data[], const double x[36], const double
            zi_data[], double y[36], double zf_data[], int zf_size[1])
{
  double a1;
  int k;
  int j;
  a1 = a_data[0];
  if ((!rtIsInf(a_data[0])) && (!rtIsNaN(a_data[0])) && (!(a_data[0] == 0.0)) &&
      (a_data[0] != 1.0)) {
    for (k = 0; k < 13; k++) {
      b_data[k] /= a1;
    }

    for (k = 0; k < 12; k++) {
      a_data[k + 1] /= a1;
    }

    a_data[0] = 1.0;
  }

  zf_size[0] = 12;
  for (k = 0; k < 12; k++) {
    zf_data[k] = 0.0;
    y[k] = zi_data[k];
  }

  std::memset(&y[12], 0, 24U * sizeof(double));
  for (k = 0; k < 36; k++) {
    int naxpy;
    int y_tmp;
    if (36 - k < 13) {
      naxpy = 35 - k;
    } else {
      naxpy = 12;
    }

    for (j = 0; j <= naxpy; j++) {
      y_tmp = k + j;
      y[y_tmp] += x[k] * b_data[j];
    }

    if (35 - k < 12) {
      naxpy = 34 - k;
    } else {
      naxpy = 11;
    }

    a1 = -y[k];
    for (j = 0; j <= naxpy; j++) {
      y_tmp = (k + j) + 1;
      y[y_tmp] += a1 * a_data[j + 1];
    }
  }

  for (k = 0; k < 12; k++) {
    for (j = 0; j <= k; j++) {
      zf_data[j] += x[k + 24] * b_data[(j - k) + 12];
    }
  }

  for (k = 0; k < 12; k++) {
    for (j = 0; j <= k; j++) {
      zf_data[j] += -y[k + 24] * a_data[(j - k) + 12];
    }
  }
}

//
// File trailer for filter.cpp
//
// [EOF]
//
