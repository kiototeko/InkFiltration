//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: sortIdx.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 07-May-2021 23:24:34
//

// Include Files
#include "sortIdx.h"
#include "getPeaksA.h"
#include "getPeaksPre.h"
#include "rt_nonfinite.h"
#include <cstring>

// Function Declarations
static void merge(int idx_data[], int x_data[], int offset, int np, int nq, int
                  iwork_data[], int xwork_data[]);

// Function Definitions

//
// Arguments    : int idx_data[]
//                int x_data[]
//                int offset
//                int np
//                int nq
//                int iwork_data[]
//                int xwork_data[]
// Return Type  : void
//
static void merge(int idx_data[], int x_data[], int offset, int np, int nq, int
                  iwork_data[], int xwork_data[])
{
  if (nq != 0) {
    int n_tmp;
    int j;
    int p;
    int iout;
    int q;
    n_tmp = np + nq;
    for (j = 0; j < n_tmp; j++) {
      iout = offset + j;
      iwork_data[j] = idx_data[iout];
      xwork_data[j] = x_data[iout];
    }

    p = 0;
    q = np;
    iout = offset - 1;
    int exitg1;
    do {
      exitg1 = 0;
      iout++;
      if (xwork_data[p] <= xwork_data[q]) {
        idx_data[iout] = iwork_data[p];
        x_data[iout] = xwork_data[p];
        if (p + 1 < np) {
          p++;
        } else {
          exitg1 = 1;
        }
      } else {
        idx_data[iout] = iwork_data[q];
        x_data[iout] = xwork_data[q];
        if (q + 1 < n_tmp) {
          q++;
        } else {
          q = iout - p;
          for (j = p + 1; j <= np; j++) {
            iout = q + j;
            idx_data[iout] = iwork_data[j - 1];
            x_data[iout] = xwork_data[j - 1];
          }

          exitg1 = 1;
        }
      }
    } while (exitg1 == 0);
  }
}

//
// Arguments    : int x_data[]
//                const int x_size[1]
//                int idx_data[]
//                int idx_size[1]
// Return Type  : void
//
void sortIdx(int x_data[], const int x_size[1], int idx_data[], int idx_size[1])
{
  signed char unnamed_idx_0;
  int i3;
  int x4[4];
  unsigned char idx4[4];
  int iwork_data[90];
  int xwork_data[90];
  int nPairs;
  signed char perm[4];
  unnamed_idx_0 = static_cast<signed char>(x_size[0]);
  idx_size[0] = unnamed_idx_0;
  i3 = unnamed_idx_0;
  if (0 <= i3 - 1) {
    std::memset(&idx_data[0], 0, i3 * sizeof(int));
  }

  if (x_size[0] != 0) {
    int n;
    int nQuartets;
    int i4;
    int nLeft;
    int i2;
    int i1;
    n = x_size[0];
    x4[0] = 0;
    idx4[0] = 0U;
    x4[1] = 0;
    idx4[1] = 0U;
    x4[2] = 0;
    idx4[2] = 0U;
    x4[3] = 0;
    idx4[3] = 0U;
    i3 = unnamed_idx_0;
    if (0 <= i3 - 1) {
      std::memset(&iwork_data[0], 0, i3 * sizeof(int));
    }

    i3 = x_size[0];
    if (0 <= i3 - 1) {
      std::memset(&xwork_data[0], 0, i3 * sizeof(int));
    }

    nQuartets = x_size[0] >> 2;
    for (int j = 0; j < nQuartets; j++) {
      int i;
      i = j << 2;
      idx4[0] = static_cast<unsigned char>(i + 1);
      idx4[1] = static_cast<unsigned char>(i + 2);
      idx4[2] = static_cast<unsigned char>(i + 3);
      idx4[3] = static_cast<unsigned char>(i + 4);
      x4[0] = x_data[i];
      i3 = x_data[i + 1];
      x4[1] = i3;
      i4 = x_data[i + 2];
      x4[2] = i4;
      nLeft = x_data[i + 3];
      x4[3] = nLeft;
      if (x_data[i] <= i3) {
        i1 = 1;
        i2 = 2;
      } else {
        i1 = 2;
        i2 = 1;
      }

      if (i4 <= nLeft) {
        i3 = 3;
        i4 = 4;
      } else {
        i3 = 4;
        i4 = 3;
      }

      nLeft = x4[i1 - 1];
      nPairs = x4[i3 - 1];
      if (nLeft <= nPairs) {
        nLeft = x4[i2 - 1];
        if (nLeft <= nPairs) {
          perm[0] = static_cast<signed char>(i1);
          perm[1] = static_cast<signed char>(i2);
          perm[2] = static_cast<signed char>(i3);
          perm[3] = static_cast<signed char>(i4);
        } else if (nLeft <= x4[i4 - 1]) {
          perm[0] = static_cast<signed char>(i1);
          perm[1] = static_cast<signed char>(i3);
          perm[2] = static_cast<signed char>(i2);
          perm[3] = static_cast<signed char>(i4);
        } else {
          perm[0] = static_cast<signed char>(i1);
          perm[1] = static_cast<signed char>(i3);
          perm[2] = static_cast<signed char>(i4);
          perm[3] = static_cast<signed char>(i2);
        }
      } else {
        nPairs = x4[i4 - 1];
        if (nLeft <= nPairs) {
          if (x4[i2 - 1] <= nPairs) {
            perm[0] = static_cast<signed char>(i3);
            perm[1] = static_cast<signed char>(i1);
            perm[2] = static_cast<signed char>(i2);
            perm[3] = static_cast<signed char>(i4);
          } else {
            perm[0] = static_cast<signed char>(i3);
            perm[1] = static_cast<signed char>(i1);
            perm[2] = static_cast<signed char>(i4);
            perm[3] = static_cast<signed char>(i2);
          }
        } else {
          perm[0] = static_cast<signed char>(i3);
          perm[1] = static_cast<signed char>(i4);
          perm[2] = static_cast<signed char>(i1);
          perm[3] = static_cast<signed char>(i2);
        }
      }

      nPairs = perm[0] - 1;
      idx_data[i] = idx4[nPairs];
      i1 = perm[1] - 1;
      idx_data[i + 1] = idx4[i1];
      i3 = perm[2] - 1;
      idx_data[i + 2] = idx4[i3];
      i4 = perm[3] - 1;
      idx_data[i + 3] = idx4[i4];
      x_data[i] = x4[nPairs];
      x_data[i + 1] = x4[i1];
      x_data[i + 2] = x4[i3];
      x_data[i + 3] = x4[i4];
    }

    i4 = nQuartets << 2;
    nLeft = (x_size[0] - i4) - 1;
    if (nLeft + 1 > 0) {
      for (i2 = 0; i2 <= nLeft; i2++) {
        i3 = i4 + i2;
        idx4[i2] = static_cast<unsigned char>(i3 + 1);
        x4[i2] = x_data[i3];
      }

      perm[1] = 0;
      perm[2] = 0;
      perm[3] = 0;
      if (nLeft + 1 == 1) {
        perm[0] = 1;
      } else if (nLeft + 1 == 2) {
        if (x4[0] <= x4[1]) {
          perm[0] = 1;
          perm[1] = 2;
        } else {
          perm[0] = 2;
          perm[1] = 1;
        }
      } else if (x4[0] <= x4[1]) {
        if (x4[1] <= x4[2]) {
          perm[0] = 1;
          perm[1] = 2;
          perm[2] = 3;
        } else if (x4[0] <= x4[2]) {
          perm[0] = 1;
          perm[1] = 3;
          perm[2] = 2;
        } else {
          perm[0] = 3;
          perm[1] = 1;
          perm[2] = 2;
        }
      } else if (x4[0] <= x4[2]) {
        perm[0] = 2;
        perm[1] = 1;
        perm[2] = 3;
      } else if (x4[1] <= x4[2]) {
        perm[0] = 2;
        perm[1] = 3;
        perm[2] = 1;
      } else {
        perm[0] = 3;
        perm[1] = 2;
        perm[2] = 1;
      }

      for (i2 = 0; i2 <= nLeft; i2++) {
        nPairs = perm[i2] - 1;
        i1 = i4 + i2;
        idx_data[i1] = idx4[nPairs];
        x_data[i1] = x4[nPairs];
      }
    }

    if (n > 1) {
      nPairs = n >> 2;
      nLeft = 4;
      while (nPairs > 1) {
        if ((nPairs & 1) != 0) {
          nPairs--;
          i3 = nLeft * nPairs;
          i4 = n - i3;
          if (i4 > nLeft) {
            merge(idx_data, x_data, i3, nLeft, i4 - nLeft, iwork_data,
                  xwork_data);
          }
        }

        i3 = nLeft << 1;
        nPairs >>= 1;
        for (i2 = 0; i2 < nPairs; i2++) {
          merge(idx_data, x_data, i2 * i3, nLeft, nLeft, iwork_data, xwork_data);
        }

        nLeft = i3;
      }

      if (n > nLeft) {
        merge(idx_data, x_data, 0, nLeft, n - nLeft, iwork_data, xwork_data);
      }
    }
  }
}

//
// File trailer for sortIdx.cpp
//
// [EOF]
//
