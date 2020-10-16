//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: CXSparseAPI.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 13-Oct-2020 20:04:12
//

// Include Files
#include "CXSparseAPI.h"
#include "getPeaksA.h"
#include "getPeaksPre.h"
#include "makeCXSparseMatrix.h"
#include "rt_nonfinite.h"
#include "solve_from_lu.h"
#include "solve_from_qr.h"
#include "sparse.h"

// Type Definitions
#include "cs.h"

// Function Definitions

//
// Arguments    : const coder_internal_sparse *A
//                double b[12]
// Return Type  : void
//
void CXSparseAPI::iteratedSolve(const coder_internal_sparse *A, double b[12])
{
  cs_di* cxA;
  cs_dis * S;
  cs_din * N;
  double tol;
  cxA = makeCXSparseMatrix(A->nnzInt(), 12, 12, &(((coder::array<int, 1U> *)
    &A->colidx)->data())[0], &(((coder::array<int, 1U> *)&A->rowidx)->data())[0],
    &(((coder::array<double, 1U> *)&A->d)->data())[0]);
  S = cs_di_sqr(2, cxA, 0);
  N = cs_di_lu(cxA, S, 1);
  cs_di_spfree(cxA);
  if (N == NULL) {
    cs_di_sfree(S);
    cs_di_nfree(N);
    cxA = makeCXSparseMatrix(A->nnzInt(), 12, 12, &(((coder::array<int, 1U> *)
      &A->colidx)->data())[0], &(((coder::array<int, 1U> *)&A->rowidx)->data())
      [0], &(((coder::array<double, 1U> *)&A->d)->data())[0]);
    S = cs_di_sqr(2, cxA, 1);
    N = cs_di_qr(cxA, S);
    cs_di_spfree(cxA);
    qr_rank_di(N, &tol);
    solve_from_qr_di(N, S, (double *)&b[0], 12, 12);
    cs_di_sfree(S);
    cs_di_nfree(N);
  } else {
    solve_from_lu_di(N, S, (double *)&b[0], 12);
    cs_di_sfree(S);
    cs_di_nfree(N);
  }
}

//
// File trailer for CXSparseAPI.cpp
//
// [EOF]
//
