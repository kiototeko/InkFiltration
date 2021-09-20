//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: getPeaksGlobal_initialize.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 07-May-2021 23:24:34
//

// Include Files
#include "getPeaksGlobal_initialize.h"
#include "getPeaksA.h"
#include "getPeaksGlobal_data.h"
#include "getPeaksPre.h"
#include "rt_nonfinite.h"

// Function Definitions

//
// Arguments    : void
// Return Type  : void
//
void getPeaksGlobal_initialize()
{
  rt_InitInfAndNaN();
  isInitialized_getPeaksGlobal = true;
}

//
// File trailer for getPeaksGlobal_initialize.cpp
//
// [EOF]
//
