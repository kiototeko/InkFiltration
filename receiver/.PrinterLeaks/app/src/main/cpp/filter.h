//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: filter.h
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 07-May-2021 23:24:34
//
#ifndef FILTER_H
#define FILTER_H

// Include Files
#include <cstddef>
#include <cstdlib>
#include "rtwtypes.h"
#include "getPeaksGlobal_types.h"

// Function Declarations
extern void b_filter(double b_data[], double a_data[], const double x[36], const
                     double zi_data[], double y[36]);
extern void filter(double b_data[], double a_data[], const double x[36], const
                   double zi_data[], double y[36], double zf_data[], int
                   zf_size[1]);

#endif

//
// File trailer for filter.h
//
// [EOF]
//
