//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: getPeaksPre.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 13-Oct-2020 20:04:12
//

// Include Files
#include "getPeaksPre.h"
#include "envelope.h"
#include "filtfilt.h"
#include "getPeaksA.h"
#include "getPeaksGlobal_data.h"
#include "getPeaksGlobal_initialize.h"
#include "rt_nonfinite.h"
#include <cmath>
#include <cstring>

// Function Definitions

//
// Arguments    : const double y[529200]
//                const double sample[179]
//                int window
//                int minH
//                double p_data[]
//                int p_size[2]
// Return Type  : void
//
void getPeaksPre(const double y[529200], const double sample[179], int window,
                 int minH, double p_data[], int p_size[2])
{
  static double yband[529200];
  static double ff[529200];
  static double unusedU0[529200];
  int k;
  double s;
  double c[1059];
  double x[530];
  int ihi;
  int i;
  short tmp_data[1059];
  if (!isInitialized_getPeaksGlobal) {
    getPeaksGlobal_initialize();
  }

  b_filtfilt(y, yband);
  b_envelope(yband, window, ff, unusedU0);
  for (k = 0; k < 529200; k++) {
    unusedU0[k] = std::abs(ff[k] * ff[k]);
  }

  s = unusedU0[0];
  for (k = 0; k < 529199; k++) {
    s += unusedU0[k + 1];
  }

  s = std::sqrt(s / 529200.0);
  for (k = 0; k < 530; k++) {
    x[k] = ff[1000 * k] / s;
  }

  std::memset(&c[0], 0, 1059U * sizeof(double));
  for (k = 0; k < 530; k++) {
    if (530 - k < 179) {
      ihi = 529 - k;
    } else {
      ihi = 178;
    }

    s = 0.0;
    for (i = 0; i <= ihi; i++) {
      s += sample[i] * x[k + i];
    }

    c[k + 529] = s;
  }

  for (k = 0; k < 529; k++) {
    ihi = 177 - k;
    s = 0.0;
    for (i = 0; i <= ihi; i++) {
      s += sample[(k + i) + 1] * x[i];
    }

    c[528 - k] = s;
  }

  ihi = 0;
  k = 0;
  for (i = 0; i < 1059; i++) {
    if (c[i] > minH) {
      ihi++;
      tmp_data[k] = static_cast<short>(i + 1);
      k++;
    }
  }

  p_size[0] = 1;
  p_size[1] = ihi;
  for (k = 0; k < ihi; k++) {
    p_data[k] = (static_cast<double>(tmp_data[k]) - 1.0) - 529.0;
  }
}

//
// File trailer for getPeaksPre.cpp
//
// [EOF]
//
