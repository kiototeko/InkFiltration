//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: getPeaksA_initialize.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 12-Oct-2020 21:50:35
//

// Include Files
#include "getPeaksA_initialize.h"
#include "getPeaksA.h"
#include "getPeaksA_data.h"
#include "rt_nonfinite.h"

// Function Definitions

//
// Arguments    : void
// Return Type  : void
//
void getPeaksA_initialize()
{
  rt_InitInfAndNaN();
  isInitialized_getPeaksA = true;
}

//
// File trailer for getPeaksA_initialize.cpp
//
// [EOF]
//
