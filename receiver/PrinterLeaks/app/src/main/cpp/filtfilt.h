//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: filtfilt.h
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 07-May-2021 23:24:34
//
#ifndef FILTFILT_H
#define FILTFILT_H

// Include Files
#include <cstddef>
#include <cstdlib>
#include "rtwtypes.h"
#include "getPeaksGlobal_types.h"

// Function Declarations
extern void b_filtfilt(const double x[529200], double y[529200]);
extern void filtfilt(const double b[13], const double a[13], const double x
                     [44100], double y[44100]);

#endif

//
// File trailer for filtfilt.h
//
// [EOF]
//
