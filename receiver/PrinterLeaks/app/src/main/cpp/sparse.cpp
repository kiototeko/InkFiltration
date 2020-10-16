//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: sparse.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 13-Oct-2020 20:04:12
//

// Include Files
#include "sparse.h"
#include "CXSparseAPI.h"
#include "getPeaksA.h"
#include "getPeaksGlobal_data.h"
#include "getPeaksPre.h"
#include "introsort.h"
#include "rt_nonfinite.h"
#include <cstring>

// Function Definitions

//
// Arguments    : const double y[34]
// Return Type  : void
//
void coder_internal_sparse::init(const double y[34])
{
  int cptr;
  int sortedIndices[34];
  signed char cidxInt[34];
  int c;
  signed char ridxInt[34];
  double val;
  for (cptr = 0; cptr < 34; cptr++) {
    sortedIndices[cptr] = cptr + 1;
  }

  introsort(sortedIndices);
  this->d.set_size(34);
  this->colidx.set_size(13);
  this->colidx[0] = 1;
  this->rowidx.set_size(34);
  for (cptr = 0; cptr < 34; cptr++) {
    cidxInt[cptr] = iv[sortedIndices[cptr] - 1];
    ridxInt[cptr] = iv1[sortedIndices[cptr] - 1];
    this->d[cptr] = 0.0;
    this->rowidx[cptr] = 0;
  }

  cptr = 0;
  for (c = 0; c < 12; c++) {
    while ((cptr + 1 <= 34) && (cidxInt[cptr] == c + 1)) {
      this->rowidx[cptr] = ridxInt[cptr];
      cptr++;
    }

    this->colidx[c + 1] = cptr + 1;
  }

  for (cptr = 0; cptr < 34; cptr++) {
    this->d[cptr] = y[sortedIndices[cptr] - 1];
  }

  cptr = 1;
  for (c = 0; c < 12; c++) {
    int ridx;
    ridx = this->colidx[c];
    this->colidx[c] = cptr;
    int exitg1;
    int i;
    do {
      exitg1 = 0;
      i = this->colidx[c + 1];
      if (ridx < i) {
        int currRowIdx_tmp;
        val = 0.0;
        currRowIdx_tmp = this->rowidx[ridx - 1];
        while ((ridx < i) && (this->rowidx[ridx - 1] == currRowIdx_tmp)) {
          val += this->d[ridx - 1];
          ridx++;
        }

        if (val != 0.0) {
          this->d[cptr - 1] = val;
          this->rowidx[cptr - 1] = currRowIdx_tmp;
          cptr++;
        }
      } else {
        exitg1 = 1;
      }
    } while (exitg1 == 0);
  }

  this->colidx[12] = cptr;
}

//
// Arguments    : const double b[12]
//                double y[12]
// Return Type  : void
//
void coder_internal_sparse::mldivide(const double b[12], double y[12]) const
{
  std::memcpy(&y[0], &b[0], 12U * sizeof(double));
  CXSparseAPI::iteratedSolve((this), (y));
}

//
// Arguments    : void
// Return Type  : int
//
int coder_internal_sparse::nnzInt() const
{
  return this->colidx[this->colidx.size(0) - 1] - 1;
}

//
// File trailer for sparse.cpp
//
// [EOF]
//
