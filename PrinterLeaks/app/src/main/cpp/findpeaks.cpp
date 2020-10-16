//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: findpeaks.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 13-Oct-2020 20:04:12
//

// Include Files
#include "findpeaks.h"
#include "eml_setop.h"
#include "getPeaksA.h"
#include "getPeaksPre.h"
#include "rt_nonfinite.h"
#include "sort.h"
#include <cstring>

// Function Declarations
static void c_findPeaksSeparatedByMoreThanM(const double y[45], const int
  iPk_data[], const int iPk_size[1], int Pd, int idx_data[], int idx_size[1]);

// Function Definitions

//
// Arguments    : const double y[45]
//                const int iPk_data[]
//                const int iPk_size[1]
//                int Pd
//                int idx_data[]
//                int idx_size[1]
// Return Type  : void
//
static void c_findPeaksSeparatedByMoreThanM(const double y[45], const int
  iPk_data[], const int iPk_size[1], int Pd, int idx_data[], int idx_size[1])
{
  int sortIdx_data[90];
  int k;
  signed char locs_temp_data[90];
  boolean_T idelete_data[90];
  int qEnd;
  signed char tmp_data[90];
  int iwork_data[90];
  boolean_T b_tmp_data[90];
  if ((iPk_size[0] == 0) || (Pd == 0)) {
    int n;
    if (iPk_size[0] < 1) {
      n = 0;
    } else {
      n = iPk_size[0];
    }

    if (n > 0) {
      int i2;
      sortIdx_data[0] = 1;
      i2 = 1;
      for (k = 2; k <= n; k++) {
        i2++;
        sortIdx_data[k - 1] = i2;
      }
    }

    idx_size[0] = n;
    if (0 <= n - 1) {
      std::memcpy(&idx_data[0], &sortIdx_data[0], n * sizeof(int));
    }
  } else {
    int n;
    int sortIdx_size_idx_0;
    int i2;
    int i;
    int i1;
    int b_i;
    int j;
    int pEnd;
    n = iPk_size[0] + 1;
    sortIdx_size_idx_0 = static_cast<signed char>(iPk_size[0]);
    i2 = static_cast<signed char>(iPk_size[0]);
    if (0 <= i2 - 1) {
      std::memset(&sortIdx_data[0], 0, i2 * sizeof(int));
    }

    i = iPk_size[0] - 1;
    for (k = 1; k <= i; k += 2) {
      i1 = iPk_data[k - 1] - 1;
      if ((y[i1] >= y[iPk_data[k] - 1]) || rtIsNaN(y[i1])) {
        sortIdx_data[k - 1] = k;
        sortIdx_data[k] = k + 1;
      } else {
        sortIdx_data[k - 1] = k + 1;
        sortIdx_data[k] = k;
      }
    }

    if ((iPk_size[0] & 1) != 0) {
      sortIdx_data[iPk_size[0] - 1] = iPk_size[0];
    }

    b_i = 2;
    while (b_i < n - 1) {
      i2 = b_i << 1;
      j = 1;
      for (pEnd = b_i + 1; pEnd < n; pEnd = qEnd + b_i) {
        int p;
        int q;
        int kEnd;
        p = j - 1;
        q = pEnd;
        qEnd = j + i2;
        if (qEnd > n) {
          qEnd = n;
        }

        k = 0;
        kEnd = qEnd - j;
        while (k + 1 <= kEnd) {
          i = iPk_data[sortIdx_data[p] - 1] - 1;
          i1 = sortIdx_data[q - 1];
          if ((y[i] >= y[iPk_data[i1 - 1] - 1]) || rtIsNaN(y[i])) {
            iwork_data[k] = sortIdx_data[p];
            p++;
            if (p + 1 == pEnd) {
              while (q < qEnd) {
                k++;
                iwork_data[k] = sortIdx_data[q - 1];
                q++;
              }
            }
          } else {
            iwork_data[k] = i1;
            q++;
            if (q == qEnd) {
              while (p + 1 < pEnd) {
                k++;
                iwork_data[k] = sortIdx_data[p];
                p++;
              }
            }
          }

          k++;
        }

        for (k = 0; k < kEnd; k++) {
          sortIdx_data[(j + k) - 1] = iwork_data[k];
        }

        j = qEnd;
      }

      b_i = i2;
    }

    for (i = 0; i < sortIdx_size_idx_0; i++) {
      locs_temp_data[i] = static_cast<signed char>(static_cast<signed char>
        (iPk_data[sortIdx_data[i] - 1] - 1) + 1);
    }

    if (0 <= sortIdx_size_idx_0 - 1) {
      std::memset(&idelete_data[0], 0, sortIdx_size_idx_0 * sizeof(boolean_T));
    }

    for (b_i = 0; b_i < sortIdx_size_idx_0; b_i++) {
      if (!idelete_data[b_i]) {
        double d;
        i = static_cast<signed char>(static_cast<signed char>
          (iPk_data[sortIdx_data[b_i] - 1] - 1) + 1);
        d = static_cast<double>(i) - static_cast<double>(Pd);
        if (d < 2.147483648E+9) {
          if (d >= -2.147483648E+9) {
            i1 = static_cast<int>(d);
          } else {
            i1 = MIN_int32_T;
          }
        } else {
          i1 = MAX_int32_T;
        }

        d = static_cast<double>(i) + static_cast<double>(Pd);
        if (d < 2.147483648E+9) {
          if (d >= -2.147483648E+9) {
            i = static_cast<int>(d);
          } else {
            i = MIN_int32_T;
          }
        } else {
          i = MAX_int32_T;
        }

        for (i2 = 0; i2 < sortIdx_size_idx_0; i2++) {
          b_tmp_data[i2] = ((locs_temp_data[i2] >= i1) && (locs_temp_data[i2] <=
            i));
        }

        for (i = 0; i < sortIdx_size_idx_0; i++) {
          idelete_data[i] = (idelete_data[i] || b_tmp_data[i]);
        }

        idelete_data[b_i] = false;
      }
    }

    i2 = sortIdx_size_idx_0 - 1;
    pEnd = 0;
    j = 0;
    for (b_i = 0; b_i <= i2; b_i++) {
      if (!idelete_data[b_i]) {
        pEnd++;
        tmp_data[j] = static_cast<signed char>(b_i + 1);
        j++;
      }
    }

    idx_size[0] = pEnd;
    for (i = 0; i < pEnd; i++) {
      idx_data[i] = sortIdx_data[tmp_data[i] - 1];
    }

    sort(idx_data, idx_size);
  }
}

//
// Arguments    : const double Yin[45]
//                double varargin_2
//                int varargin_4
//                double Ypk_data[]
//                int Ypk_size[1]
//                double Xpk_data[]
//                int Xpk_size[1]
// Return Type  : void
//
void findpeaks(const double Yin[45], double varargin_2, int varargin_4, double
               Ypk_data[], int Ypk_size[1], double Xpk_data[], int Xpk_size[1])
{
  int nPk;
  int nInf;
  char dir;
  int kfirst;
  double ykfirst;
  boolean_T isinfykfirst;
  int k;
  double yk;
  int n;
  signed char iFinite_data[45];
  int b_iFinite_data[45];
  int iInfinite_data[45];
  int iInfinite_size[1];
  int iPk_size[1];
  int iPk_data[45];
  int c_data[90];
  int c_size[1];
  int iInflect_data[45];
  int iInflect_size[1];
  int iFinite_size[1];
  int idx_data[90];
  int b_iPk_data[90];
  nPk = -1;
  nInf = -1;
  dir = 'n';
  kfirst = -1;
  ykfirst = rtInf;
  isinfykfirst = true;
  for (k = 0; k < 45; k++) {
    boolean_T isinfyk;
    yk = Yin[k];
    if (rtIsNaN(Yin[k])) {
      yk = rtInf;
      isinfyk = true;
    } else if (rtIsInf(Yin[k]) && (Yin[k] > 0.0)) {
      isinfyk = true;
      nInf++;
      iInfinite_data[nInf] = k + 1;
    } else {
      isinfyk = false;
    }

    if (yk != ykfirst) {
      char previousdir;
      previousdir = dir;
      if (isinfyk || isinfykfirst) {
        dir = 'n';
      } else if (yk < ykfirst) {
        dir = 'd';
        if (('d' != previousdir) && (previousdir == 'i')) {
          nPk++;
          b_iFinite_data[nPk] = kfirst + 1;
        }
      } else {
        dir = 'i';
      }

      ykfirst = yk;
      kfirst = k;
      isinfykfirst = isinfyk;
    }
  }

  if (1 > nPk + 1) {
    nPk = -1;
  }

  n = nPk + 1;
  for (k = 0; k <= nPk; k++) {
    iFinite_data[k] = static_cast<signed char>(b_iFinite_data[k]);
  }

  for (k = 0; k < n; k++) {
    b_iFinite_data[k] = iFinite_data[k];
  }

  if (1 > nInf + 1) {
    nPk = -1;
  } else {
    nPk = nInf;
  }

  kfirst = nPk + 1;
  for (k = 0; k <= nPk; k++) {
    iFinite_data[k] = static_cast<signed char>(iInfinite_data[k]);
  }

  iInfinite_size[0] = kfirst;
  for (k = 0; k < kfirst; k++) {
    iInfinite_data[k] = iFinite_data[k];
  }

  nPk = 0;
  for (k = 0; k < n; k++) {
    ykfirst = Yin[b_iFinite_data[k] - 1];
    if (ykfirst > varargin_2) {
      if ((Yin[b_iFinite_data[k] - 2] > Yin[b_iFinite_data[k]]) || rtIsNaN
          (Yin[b_iFinite_data[k]])) {
        yk = Yin[b_iFinite_data[k] - 2];
      } else {
        yk = Yin[b_iFinite_data[k]];
      }

      if (ykfirst - yk >= 0.0) {
        nPk++;
        iPk_data[nPk - 1] = b_iFinite_data[k];
      }
    }
  }

  if (1 > nPk) {
    iPk_size[0] = 0;
  } else {
    iPk_size[0] = nPk;
  }

  do_vectors(iPk_data, iPk_size, iInfinite_data, iInfinite_size, c_data, c_size,
             iInflect_data, iInflect_size, b_iFinite_data, iFinite_size);
  c_findPeaksSeparatedByMoreThanM(Yin, c_data, c_size, varargin_4, idx_data,
    iInfinite_size);
  if (iInfinite_size[0] > 45) {
    std::memcpy(&b_iPk_data[0], &idx_data[0], 45U * sizeof(int));
    iInfinite_size[0] = 45;
    std::memcpy(&idx_data[0], &b_iPk_data[0], 45U * sizeof(int));
  }

  kfirst = iInfinite_size[0];
  nPk = iInfinite_size[0];
  for (k = 0; k < nPk; k++) {
    b_iPk_data[k] = c_data[idx_data[k] - 1];
  }

  Ypk_size[0] = iInfinite_size[0];
  for (k = 0; k < kfirst; k++) {
    Ypk_data[k] = Yin[b_iPk_data[k] - 1];
  }

  Xpk_size[0] = iInfinite_size[0];
  for (k = 0; k < kfirst; k++) {
    Xpk_data[k] = static_cast<signed char>(static_cast<signed char>(b_iPk_data[k]
      - 1) + 1);
  }
}

//
// File trailer for findpeaks.cpp
//
// [EOF]
//
