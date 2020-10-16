//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: getPeaksGlobal_types.h
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 13-Oct-2020 20:04:12
//
#ifndef GETPEAKSGLOBAL_TYPES_H
#define GETPEAKSGLOBAL_TYPES_H

// Include Files
#include "rtwtypes.h"
#include "coder_array.h"
#ifdef _MSC_VER

#pragma warning(push)
#pragma warning(disable : 4251)

#endif

// Type Definitions
class coder_internal_sparse
{
 public:
  void init(const double y[34]);
  void mldivide(const double b[12], double y[12]) const;
  int nnzInt() const;
  coder::array<double, 1U> d;
  coder::array<int, 1U> colidx;
  coder::array<int, 1U> rowidx;
};

class CXSparseAPI
{
 public:
  static void iteratedSolve(const coder_internal_sparse *A, double b[12]);
};

#ifdef _MSC_VER

#pragma warning(pop)

#endif
#endif

//
// File trailer for getPeaksGlobal_types.h
//
// [EOF]
//
