//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: getPeaksA.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 07-May-2021 23:24:34
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
//                double window
//                double printer
//                double peakdis
//                double p_data[]
//                int p_size[1]
// Return Type  : void
//
void getPeaksA(const double y[44100], double minH, double window, double printer,
               double peakdis, double p_data[], int p_size[1])
{
  double b[13];
  static const double b_b[13] = { 0.0017182013145110864, -0.014858534892777144,
    0.06102835104997309, -0.15911055890722281, 0.29666935432734687,
    -0.42152722932683179, 0.47216083438062795, -0.42152722932683195,
    0.29666935432734709, -0.159110558907223, 0.061028351049973187,
    -0.014858534892777164, 0.0017182013145110883 };

  double c[13];
  static const double c_b[13] = { 0.0020178111587994944, -0.0069807719931024382,
    0.015827661311422037, -0.026437269910251502, 0.037312674135295085,
    -0.044323626195502883, 0.047082830317763343, -0.044323626195502945,
    0.037312674135295175, -0.026437269910251589, 0.015827661311422103,
    -0.006980771993102472, 0.0020178111587995026 };

  static const double b_c[13] = { 1.0, -10.533533544462736, 51.5974290353368,
    -155.38500218245173, 320.36130901115564, -476.332438260312,
    523.70200144670878, -428.98095012037084, 259.842396831883,
    -113.51503937269817, 33.955082800276777, -6.2456814017096205,
    0.534427267270428 };

  static const double d_b[13] = { 0.030893168412676079, 0.028685012992158879,
    -0.089329411088991173, -0.040367898165424437, 0.18209333026767413,
    0.023800879316182744, -0.22259505142455344, 0.023800879316183909,
    0.18209333026767391, -0.040367898165425131, -0.089329411088990909,
    0.028685012992159153, 0.030893168412676059 };

  static const double c_c[13] = { 1.0, -4.4129034671490244, 13.169284960290835,
    -26.741857170822783, 43.197819016931142, -54.719664319125876,
    57.414587309149795, -48.542200460770019, 33.990635998799917,
    -18.65244716665309, 8.1413909033451439, -2.4142634341243978,
    0.48540515900485515 };

  static double yband[44100];
  static const double d_c[13] = { 1.0, 2.6732072764606905, 4.4493133230187567,
    5.9900606540498114, 7.5108393341458743, 7.7489434088177109, 6.91864609353785,
    5.35817891775092, 3.7324355730969612, 2.1111252201998774, 1.0151044938576039,
    0.35447278064394472, 0.092784912039031914 };

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

  if (printer == 2.0) {
    std::memcpy(&b[0], &dv[0], 13U * sizeof(double));
    std::memcpy(&c[0], &dv1[0], 13U * sizeof(double));
  } else if (printer == 3.0) {
    std::memcpy(&b[0], &b_b[0], 13U * sizeof(double));
    std::memcpy(&c[0], &b_c[0], 13U * sizeof(double));
  } else if (printer == 4.0) {
    std::memcpy(&b[0], &c_b[0], 13U * sizeof(double));
    std::memcpy(&c[0], &c_c[0], 13U * sizeof(double));
  } else {
    //  printer == 5
    std::memcpy(&b[0], &d_b[0], 13U * sizeof(double));
    std::memcpy(&c[0], &d_c[0], 13U * sizeof(double));
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
}

//
// File trailer for getPeaksA.cpp
//
// [EOF]
//
