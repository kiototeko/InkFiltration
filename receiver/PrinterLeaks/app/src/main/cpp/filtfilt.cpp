//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: filtfilt.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 13-Oct-2020 20:04:12
//

// Include Files
#include "filtfilt.h"
#include "filter.h"
#include "getPeaksA.h"
#include "getPeaksGlobal_data.h"
#include "getPeaksPre.h"
#include "rt_nonfinite.h"
#include "sparse.h"
#include <cstring>

// Function Declarations
static void b_ffOneChan(const double b_data[], const double a_data[], double xc
  [529200], const double zi_data[]);
static void ffOneChan(const double b_data[], const double a_data[], double xc
                      [44100], const double zi_data[]);

// Function Definitions

//
// Arguments    : const double b_data[]
//                const double a_data[]
//                double xc[529200]
//                const double zi_data[]
// Return Type  : void
//
static void b_ffOneChan(const double b_data[], const double a_data[], double xc
  [529200], const double zi_data[])
{
  double a1;
  double b_a1;
  double d;
  int yc2_tmp;
  double b_b_data[13];
  double xt[36];
  double b_a_data[13];
  double b_zi_data[12];
  double b_xt[36];
  double zo_data[12];
  int zo_size[1];
  boolean_T b;
  boolean_T b1;
  int k;
  static double yc2[529200];
  int naxpy;
  int j;
  static double yc5[529200];
  a1 = a_data[0];
  b_a1 = a_data[0];
  d = 2.0 * xc[0];
  for (yc2_tmp = 0; yc2_tmp < 36; yc2_tmp++) {
    xt[yc2_tmp] = -xc[36 - yc2_tmp] + d;
  }

  std::memcpy(&b_b_data[0], &b_data[0], 13U * sizeof(double));
  std::memcpy(&b_a_data[0], &a_data[0], 13U * sizeof(double));
  for (yc2_tmp = 0; yc2_tmp < 12; yc2_tmp++) {
    b_zi_data[yc2_tmp] = zi_data[yc2_tmp] * xt[0];
  }

  filter(b_b_data, b_a_data, xt, b_zi_data, b_xt, zo_data, zo_size);
  std::memcpy(&b_b_data[0], &b_data[0], 13U * sizeof(double));
  std::memcpy(&b_a_data[0], &a_data[0], 13U * sizeof(double));
  b = rtIsInf(a_data[0]);
  b1 = rtIsNaN(a_data[0]);
  if ((!b) && (!b1) && (!(a_data[0] == 0.0)) && (a_data[0] != 1.0)) {
    for (k = 0; k < 13; k++) {
      b_b_data[k] /= a1;
    }

    for (k = 0; k < 12; k++) {
      b_a_data[k + 1] /= a1;
    }

    b_a_data[0] = 1.0;
  }

  for (k = 0; k < 12; k++) {
    b_zi_data[k] = 0.0;
    yc2[k] = zo_data[k];
  }

  std::memset(&yc2[12], 0, 529188U * sizeof(double));
  for (k = 0; k < 529200; k++) {
    if (529200 - k < 13) {
      naxpy = 529199 - k;
    } else {
      naxpy = 12;
    }

    for (j = 0; j <= naxpy; j++) {
      yc2_tmp = k + j;
      yc2[yc2_tmp] += xc[k] * b_b_data[j];
    }

    if (529199 - k < 12) {
      naxpy = 529198 - k;
    } else {
      naxpy = 11;
    }

    a1 = -yc2[k];
    for (j = 0; j <= naxpy; j++) {
      yc2_tmp = (k + j) + 1;
      yc2[yc2_tmp] += a1 * b_a_data[j + 1];
    }
  }

  for (k = 0; k < 12; k++) {
    for (j = 0; j <= k; j++) {
      b_zi_data[j] += xc[k + 529188] * b_b_data[(j - k) + 12];
    }
  }

  for (k = 0; k < 12; k++) {
    for (j = 0; j <= k; j++) {
      b_zi_data[j] += -yc2[k + 529188] * b_a_data[(j - k) + 12];
    }
  }

  d = 2.0 * xc[529199];
  std::memcpy(&b_b_data[0], &b_data[0], 13U * sizeof(double));
  std::memcpy(&b_a_data[0], &a_data[0], 13U * sizeof(double));
  for (yc2_tmp = 0; yc2_tmp < 36; yc2_tmp++) {
    b_xt[yc2_tmp] = -xc[529198 - yc2_tmp] + d;
  }

  b_filter(b_b_data, b_a_data, b_xt, b_zi_data, xt);
  a1 = xt[35];
  std::memcpy(&b_b_data[0], &b_data[0], 13U * sizeof(double));
  std::memcpy(&b_a_data[0], &a_data[0], 13U * sizeof(double));
  for (yc2_tmp = 0; yc2_tmp < 36; yc2_tmp++) {
    b_xt[yc2_tmp] = xt[35 - yc2_tmp];
  }

  std::memcpy(&xt[0], &b_xt[0], 36U * sizeof(double));
  for (yc2_tmp = 0; yc2_tmp < 12; yc2_tmp++) {
    b_zi_data[yc2_tmp] = zi_data[yc2_tmp] * a1;
  }

  filter(b_b_data, b_a_data, xt, b_zi_data, b_xt, zo_data, zo_size);
  std::memcpy(&b_b_data[0], &b_data[0], 13U * sizeof(double));
  std::memcpy(&b_a_data[0], &a_data[0], 13U * sizeof(double));
  if ((!b) && (!b1) && (!(a_data[0] == 0.0)) && (a_data[0] != 1.0)) {
    for (k = 0; k < 13; k++) {
      b_b_data[k] /= b_a1;
    }

    for (k = 0; k < 12; k++) {
      b_a_data[k + 1] /= b_a1;
    }

    b_a_data[0] = 1.0;
  }

  std::memcpy(&yc5[0], &zo_data[0], 12U * sizeof(double));
  std::memset(&yc5[12], 0, 529188U * sizeof(double));
  for (k = 0; k < 529200; k++) {
    if (529200 - k < 13) {
      naxpy = 529199 - k;
    } else {
      naxpy = 12;
    }

    for (j = 0; j <= naxpy; j++) {
      yc2_tmp = k + j;
      yc5[yc2_tmp] += yc2[529199 - k] * b_b_data[j];
    }

    if (529199 - k < 12) {
      naxpy = 529198 - k;
    } else {
      naxpy = 11;
    }

    a1 = -yc5[k];
    for (j = 0; j <= naxpy; j++) {
      yc2_tmp = (k + j) + 1;
      yc5[yc2_tmp] += a1 * b_a_data[j + 1];
    }
  }

  for (yc2_tmp = 0; yc2_tmp < 529200; yc2_tmp++) {
    xc[yc2_tmp] = yc5[529199 - yc2_tmp];
  }
}

//
// Arguments    : const double b_data[]
//                const double a_data[]
//                double xc[44100]
//                const double zi_data[]
// Return Type  : void
//
static void ffOneChan(const double b_data[], const double a_data[], double xc
                      [44100], const double zi_data[])
{
  double a1;
  double b_a1;
  double d;
  int yc2_tmp;
  double b_b_data[13];
  double xt[36];
  double b_a_data[13];
  double b_zi_data[12];
  double b_xt[36];
  double zo_data[12];
  int zo_size[1];
  int k;
  static double yc2[44100];
  int naxpy;
  int j;
  static double yc5[44100];
  a1 = a_data[0];
  b_a1 = a_data[0];
  d = 2.0 * xc[0];
  for (yc2_tmp = 0; yc2_tmp < 36; yc2_tmp++) {
    xt[yc2_tmp] = -xc[36 - yc2_tmp] + d;
  }

  std::memcpy(&b_b_data[0], &b_data[0], 13U * sizeof(double));
  std::memcpy(&b_a_data[0], &a_data[0], 13U * sizeof(double));
  for (yc2_tmp = 0; yc2_tmp < 12; yc2_tmp++) {
    b_zi_data[yc2_tmp] = zi_data[yc2_tmp] * xt[0];
  }

  filter(b_b_data, b_a_data, xt, b_zi_data, b_xt, zo_data, zo_size);
  std::memcpy(&b_b_data[0], &b_data[0], 13U * sizeof(double));
  std::memcpy(&b_a_data[0], &a_data[0], 13U * sizeof(double));
  if ((!(a_data[0] == 0.0)) && (a_data[0] != 1.0)) {
    for (k = 0; k < 13; k++) {
      b_b_data[k] /= a1;
    }

    for (k = 0; k < 12; k++) {
      b_a_data[k + 1] /= a1;
    }

    b_a_data[0] = 1.0;
  }

  for (k = 0; k < 12; k++) {
    b_zi_data[k] = 0.0;
    yc2[k] = zo_data[k];
  }

  std::memset(&yc2[12], 0, 44088U * sizeof(double));
  for (k = 0; k < 44100; k++) {
    if (44100 - k < 13) {
      naxpy = 44099 - k;
    } else {
      naxpy = 12;
    }

    for (j = 0; j <= naxpy; j++) {
      yc2_tmp = k + j;
      yc2[yc2_tmp] += xc[k] * b_b_data[j];
    }

    if (44099 - k < 12) {
      naxpy = 44098 - k;
    } else {
      naxpy = 11;
    }

    a1 = -yc2[k];
    for (j = 0; j <= naxpy; j++) {
      yc2_tmp = (k + j) + 1;
      yc2[yc2_tmp] += a1 * b_a_data[j + 1];
    }
  }

  for (k = 0; k < 12; k++) {
    for (j = 0; j <= k; j++) {
      b_zi_data[j] += xc[k + 44088] * b_b_data[(j - k) + 12];
    }
  }

  for (k = 0; k < 12; k++) {
    for (j = 0; j <= k; j++) {
      b_zi_data[j] += -yc2[k + 44088] * b_a_data[(j - k) + 12];
    }
  }

  d = 2.0 * xc[44099];
  std::memcpy(&b_b_data[0], &b_data[0], 13U * sizeof(double));
  std::memcpy(&b_a_data[0], &a_data[0], 13U * sizeof(double));
  for (yc2_tmp = 0; yc2_tmp < 36; yc2_tmp++) {
    b_xt[yc2_tmp] = -xc[44098 - yc2_tmp] + d;
  }

  b_filter(b_b_data, b_a_data, b_xt, b_zi_data, xt);
  a1 = xt[35];
  std::memcpy(&b_b_data[0], &b_data[0], 13U * sizeof(double));
  std::memcpy(&b_a_data[0], &a_data[0], 13U * sizeof(double));
  for (yc2_tmp = 0; yc2_tmp < 36; yc2_tmp++) {
    b_xt[yc2_tmp] = xt[35 - yc2_tmp];
  }

  std::memcpy(&xt[0], &b_xt[0], 36U * sizeof(double));
  for (yc2_tmp = 0; yc2_tmp < 12; yc2_tmp++) {
    b_zi_data[yc2_tmp] = zi_data[yc2_tmp] * a1;
  }

  filter(b_b_data, b_a_data, xt, b_zi_data, b_xt, zo_data, zo_size);
  std::memcpy(&b_b_data[0], &b_data[0], 13U * sizeof(double));
  std::memcpy(&b_a_data[0], &a_data[0], 13U * sizeof(double));
  if ((!(a_data[0] == 0.0)) && (a_data[0] != 1.0)) {
    for (k = 0; k < 13; k++) {
      b_b_data[k] /= b_a1;
    }

    for (k = 0; k < 12; k++) {
      b_a_data[k + 1] /= b_a1;
    }

    b_a_data[0] = 1.0;
  }

  std::memcpy(&yc5[0], &zo_data[0], 12U * sizeof(double));
  std::memset(&yc5[12], 0, 44088U * sizeof(double));
  for (k = 0; k < 44100; k++) {
    if (44100 - k < 13) {
      naxpy = 44099 - k;
    } else {
      naxpy = 12;
    }

    for (j = 0; j <= naxpy; j++) {
      yc2_tmp = k + j;
      yc5[yc2_tmp] += yc2[44099 - k] * b_b_data[j];
    }

    if (44099 - k < 12) {
      naxpy = 44098 - k;
    } else {
      naxpy = 11;
    }

    a1 = -yc5[k];
    for (j = 0; j <= naxpy; j++) {
      yc2_tmp = (k + j) + 1;
      yc5[yc2_tmp] += a1 * b_a_data[j + 1];
    }
  }

  for (yc2_tmp = 0; yc2_tmp < 44100; yc2_tmp++) {
    xc[yc2_tmp] = yc5[44099 - yc2_tmp];
  }
}

//
// Arguments    : const double x[529200]
//                double y[529200]
// Return Type  : void
//
void b_filtfilt(const double x[529200], double y[529200])
{
  double b2_data[13];
  double a2_data[13];
  double a2[34];
  int i;
  coder_internal_sparse r;
  double b2[12];
  double zi_data[12];
  std::memcpy(&b2_data[0], &dv[0], 13U * sizeof(double));
  std::memcpy(&a2_data[0], &dv1[0], 13U * sizeof(double));
  a2[0] = a2_data[1] + 1.0;
  for (i = 0; i < 11; i++) {
    a2[i + 1] = a2_data[i + 2];
    a2[i + 12] = 1.0;
    a2[i + 23] = -1.0;
  }

  for (i = 0; i < 12; i++) {
    b2[i] = b2_data[i + 1] - b2_data[0] * a2_data[i + 1];
  }

  r.init(a2);
  r.mldivide(b2, zi_data);
  std::memcpy(&y[0], &x[0], 529200U * sizeof(double));
  b_ffOneChan(b2_data, a2_data, y, zi_data);
}

//
// Arguments    : const double b[13]
//                const double a[13]
//                const double x[44100]
//                double y[44100]
// Return Type  : void
//
void filtfilt(const double b[13], const double a[13], const double x[44100],
              double y[44100])
{
  double b_a[34];
  int i;
  coder_internal_sparse r;
  double b_b[12];
  double zi_data[12];
  b_a[0] = a[1] + 1.0;
  for (i = 0; i < 11; i++) {
    b_a[i + 1] = a[i + 2];
    b_a[i + 12] = 1.0;
    b_a[i + 23] = -1.0;
  }

  for (i = 0; i < 12; i++) {
    b_b[i] = b[i + 1] - b[0] * a[i + 1];
  }

  r.init(b_a);
  r.mldivide(b_b, zi_data);
  std::memcpy(&y[0], &x[0], 44100U * sizeof(double));
  ffOneChan(b, a, y, zi_data);
}

//
// File trailer for filtfilt.cpp
//
// [EOF]
//
