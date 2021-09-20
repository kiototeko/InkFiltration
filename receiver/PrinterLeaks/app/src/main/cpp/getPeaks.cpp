//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: getPeaks.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 19-Jul-2020 13:26:08
//

// Include Files
#include "getPeaks.h"
#include "envelope.h"
#include "filtfilt.h"
#include "findpeaks.h"
#include "getPeaks_data.h"
#include "getPeaks_initialize.h"
#include "rt_nonfinite.h"
#include <cmath>

// Function Definitions

//
// Arguments    : const double y[44100]
//                double minH
//                double p_data[]
//                int p_size[1]
// Return Type  : void
//
void getPeaks(const double y[44100], double minH, double p_data[], int p_size[1])
{
  static double yband[44100];
  static double ff[44100];
  static double unusedU0[44100];
  int k;
  double b_y;
  double b_ff[45];
  double unusedU1_data[90];
  int unusedU1_size[1];
  if (!isInitialized_getPeaks) {
    getPeaks_initialize();
  }

  filtfilt(y, yband);
  envelope(yband, ff, unusedU0);
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

  findpeaks(b_ff, minH, unusedU1_data, unusedU1_size, p_data, p_size);
}

//
// File trailer for getPeaks.cpp
//
// [EOF]
//
