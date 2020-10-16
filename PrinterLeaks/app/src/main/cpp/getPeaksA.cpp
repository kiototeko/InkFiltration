//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: getPeaksA.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 13-Oct-2020 20:04:12
//

// Include Files
#include "getPeaksA.h"
#include "envelope.h"
#include "filtfilt.h"
#include "findpeaks.h"
#include "getPeaksGlobal_data.h"
#include "getPeaksGlobal_initialize.h"
#include "getPeaksPre.h"
#include "rt_nonfinite.h"
#include <cmath>
#include <cstring>

// Function Definitions

//
// Arguments    : const double y[44100]
//                double minH
//                int window
//                int printer
//                int peakdis
//                double p_data[]
//                int p_size[1]
// Return Type  : void
//
void getPeaksA(const double y[44100], double minH, int window, int printer, int
               peakdis, double p_data[], int p_size[1])
{
  double b[13];
  static const double b_b[13] = { 0.0010399439124295445, -0.010405126530593049,
    0.049391541202183739, -0.14692425710457896, 0.304858861733178,
    -0.46468544778254722, 0.53344913337959154, -0.46468544778254817,
    0.30485886173317939, -0.14692425710457993, 0.049391541202184176,
    -0.010405126530593162, 0.0010399439124295583 };

  double c[13];
  static const double b_c[13] = { 1.0, -10.325311809372982, 50.176716252573932,
    -151.45955553675304, 315.89386571364184, -479.21612751096734,
    541.96151032635123, -460.33211028893913, 291.48841906704365,
    -134.2512066073613, 42.723584076247349, -8.445349649297583,
    0.7857302065686016 };

  static double yband[44100];
  static double ff[44100];
  static double unusedU0[44100];
  int k;
  double b_y;
  double b_ff[45];
  double unusedU1_data[90];
  int unusedU1_size[1];
  if (!isInitialized_getPeaksGlobal) {
    getPeaksGlobal_initialize();
  }

  if (printer == 3) {
    std::memcpy(&b[0], &b_b[0], 13U * sizeof(double));
    std::memcpy(&c[0], &b_c[0], 13U * sizeof(double));
  } else {
    std::memcpy(&b[0], &dv[0], 13U * sizeof(double));
    std::memcpy(&c[0], &dv1[0], 13U * sizeof(double));
  }

  filtfilt(b, c, y, yband);
  envelope(yband, window, ff, unusedU0);

  // 1000
  for (k = 0; k < 44100; k++) {
    unusedU0[k] = std::abs(ff[k] * ff[k]);
  }

  b_y = unusedU0[0];
  for (k = 0; k < 44099; k++) {
    b_y += unusedU0[k + 1];
  }

  b_y = std::sqrt(b_y / 44100.0);
  for (k = 0; k < 45; k++) {
    b_ff[k] = ff[1000 * k] / b_y;
  }

  findpeaks(b_ff, minH, peakdis, unusedU1_data, unusedU1_size, p_data, p_size);

  // findpeaks(out,'MinPeakHeight', minH, 'MinPeakDistance', peakdis);
}

//
// File trailer for getPeaksA.cpp
//
// [EOF]
//
