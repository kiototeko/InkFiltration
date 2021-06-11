//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: envelope.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 07-May-2021 23:24:34
//

// Include Files
#include "envelope.h"
#include "getPeaksA.h"
#include "getPeaksPre.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions

//
// Arguments    : const double x[529200]
//                double n
//                double upperEnv[529200]
//                double lowerEnv[529200]
// Return Type  : void
//
void b_envelope(const double x[529200], double n, double upperEnv[529200],
                double lowerEnv[529200])
{
  double s;
  int k;
  double xmean;
  int i;
  static double b_x[529200];
  int nd2;
  int n1;
  s = x[0];
  for (k = 0; k < 529199; k++) {
    s += x[k + 1];
  }

  xmean = s / 529200.0;
  for (i = 0; i < 529200; i++) {
    b_x[i] = x[i] - xmean;
  }

  k = static_cast<int>(n);
  nd2 = k >> 1;
  if ((k & 1) == 0) {
    n1 = nd2 - 2;
  } else {
    n1 = nd2 - 1;
  }

  for (i = 0; i < 529200; i++) {
    int k1;
    int k2;
    k = i - n1;
    if (k < 1) {
      k1 = 1;
    } else {
      k1 = k;
    }

    k2 = (i + nd2) + 1;
    if (k2 >= 529200) {
      k2 = 529200;
    }

    s = 0.0;
    for (k = k1; k <= k2; k++) {
      double s_tmp;
      s_tmp = b_x[k - 1];
      s += s_tmp * s_tmp;
    }

    s = std::sqrt(s / static_cast<double>((k2 - k1) + 1));
    lowerEnv[i] = xmean - s;
    s += xmean;
    upperEnv[i] = s;
  }
}

//
// Arguments    : const double x[44100]
//                double n
//                double upperEnv[44100]
//                double lowerEnv[44100]
// Return Type  : void
//
void envelope(const double x[44100], double n, double upperEnv[44100], double
              lowerEnv[44100])
{
  double s;
  int k;
  double xmean;
  int i;
  static double b_x[44100];
  int nd2;
  int n1;
  s = x[0];
  for (k = 0; k < 44099; k++) {
    s += x[k + 1];
  }

  xmean = s / 44100.0;
  for (i = 0; i < 44100; i++) {
    b_x[i] = x[i] - xmean;
  }

  k = static_cast<int>(n);
  nd2 = k >> 1;
  if ((k & 1) == 0) {
    n1 = nd2 - 2;
  } else {
    n1 = nd2 - 1;
  }

  for (i = 0; i < 44100; i++) {
    int k1;
    int k2;
    k = i - n1;
    if (k < 1) {
      k1 = 1;
    } else {
      k1 = k;
    }

    k2 = (i + nd2) + 1;
    if (k2 >= 44100) {
      k2 = 44100;
    }

    s = 0.0;
    for (k = k1; k <= k2; k++) {
      double s_tmp;
      s_tmp = b_x[k - 1];
      s += s_tmp * s_tmp;
    }

    s = std::sqrt(s / static_cast<double>((k2 - k1) + 1));
    lowerEnv[i] = xmean - s;
    s += xmean;
    upperEnv[i] = s;
  }
}

//
// File trailer for envelope.cpp
//
// [EOF]
//
