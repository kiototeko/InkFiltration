//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: getPeaks_initialize.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 19-Jul-2020 13:26:08
//

// Include Files
#include "getPeaks_initialize.h"
#include "getPeaks.h"
#include "getPeaks_data.h"
#include "rt_nonfinite.h"

// Function Definitions

//
// Arguments    : void
// Return Type  : void
//
void getPeaks_initialize()
{
  rt_InitInfAndNaN();
  isInitialized_getPeaks = true;
}

//
// File trailer for getPeaks_initialize.cpp
//
// [EOF]
//
