//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: introsort.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 13-Oct-2020 20:04:12
//

// Include Files
#include "introsort.h"
#include "getPeaksA.h"
#include "getPeaksGlobal_data.h"
#include "getPeaksPre.h"
#include "heapsort.h"
#include "insertionsort.h"
#include "rt_nonfinite.h"
#include <cstring>

// Type Definitions
struct struct_T
{
  int xstart;
  int xend;
  int depth;
};

class coder_internal_stack
{
 public:
  void init(const struct_T t0_d[20], int t0_n);
  struct_T d[20];
  int n;
};

// Function Definitions

//
// Arguments    : const struct_T t0_d[20]
//                int t0_n
// Return Type  : void
//
void coder_internal_stack::init(const struct_T t0_d[20], int t0_n)
{
  std::memcpy(&this->d[0], &t0_d[0], 20U * sizeof(struct_T));
  this->n = t0_n;
}

//
// Arguments    : int x[34]
// Return Type  : void
//
void introsort(int x[34])
{
  coder_internal_stack st;
  static const struct_T t3_d[20] = { { 1,// xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    }, { 1,                            // xstart
      34,                              // xend
      0                                // depth
    } };

  st.init(t3_d, 0);
  st.d[0].xstart = 1;
  st.d[0].xend = 34;
  st.d[0].depth = 0;
  st.n = 1;
  while (st.n > 0) {
    int expl_temp_tmp;
    struct_T expl_temp;
    int i;
    int ai;
    int s_depth;
    int b_i;
    expl_temp_tmp = st.n - 1;
    expl_temp = st.d[expl_temp_tmp];
    i = st.d[expl_temp_tmp].xstart - 1;
    ai = st.d[expl_temp_tmp].xend - 1;
    s_depth = st.d[expl_temp_tmp].depth;
    st.n = expl_temp_tmp;
    b_i = st.d[expl_temp_tmp].xend - st.d[expl_temp_tmp].xstart;
    if (b_i + 1 <= 32) {
      insertionsort(x, st.d[expl_temp_tmp].xstart, st.d[expl_temp_tmp].xend);
    } else if (st.d[expl_temp_tmp].depth == 10) {
      b_heapsort(x, st.d[expl_temp_tmp].xstart, st.d[expl_temp_tmp].xend);
    } else {
      int xmid;
      int b_ai;
      int aj;
      int t;
      int pivot;
      xmid = (st.d[expl_temp_tmp].xstart + b_i / 2) - 1;
      b_ai = iv[x[xmid] - 1];
      aj = iv[x[i] - 1];
      if ((b_ai < aj) || ((b_ai == aj) && (iv1[x[xmid] - 1] < iv1[x[i] - 1]))) {
        t = x[i];
        x[i] = x[xmid];
        x[xmid] = t;
      }

      b_ai = iv[x[ai] - 1];
      aj = iv[x[i] - 1];
      if ((b_ai < aj) || ((b_ai == aj) && (iv1[x[ai] - 1] < iv1[x[i] - 1]))) {
        t = x[i];
        x[i] = x[ai];
        x[ai] = t;
      }

      b_ai = iv[x[ai] - 1];
      aj = iv[x[xmid] - 1];
      if ((b_ai < aj) || ((b_ai == aj) && (iv1[x[ai] - 1] < iv1[x[xmid] - 1])))
      {
        t = x[xmid];
        x[xmid] = x[ai];
        x[ai] = t;
      }

      pivot = x[xmid] - 1;
      b_i = st.d[expl_temp_tmp].xend - 2;
      x[xmid] = x[b_i];
      x[b_i] = pivot + 1;
      xmid = b_i;
      aj = iv[pivot];
      b_ai = iv[pivot];
      int exitg1;
      do {
        int exitg2;
        exitg1 = 0;
        i++;
        do {
          exitg2 = 0;
          ai = iv[x[i] - 1];
          if ((ai < aj) || ((ai == aj) && (iv1[x[i] - 1] < iv1[pivot]))) {
            i++;
          } else {
            exitg2 = 1;
          }
        } while (exitg2 == 0);

        xmid--;
        do {
          exitg2 = 0;
          ai = iv[x[xmid] - 1];
          if ((b_ai < ai) || ((b_ai == ai) && (iv1[pivot] < iv1[x[xmid] - 1])))
          {
            xmid--;
          } else {
            exitg2 = 1;
          }
        } while (exitg2 == 0);

        if (i + 1 >= xmid + 1) {
          exitg1 = 1;
        } else {
          t = x[i];
          x[i] = x[xmid];
          x[xmid] = t;
        }
      } while (exitg1 == 0);

      x[b_i] = x[i];
      x[i] = pivot + 1;
      if (i + 2 < st.d[expl_temp_tmp].xend) {
        st.d[expl_temp_tmp].xstart = i + 2;
        st.d[expl_temp_tmp].xend = expl_temp.xend;
        st.d[expl_temp_tmp].depth++;
        st.n = expl_temp_tmp + 1;
      }

      if (expl_temp.xstart < i + 1) {
        st.d[st.n].xstart = expl_temp.xstart;
        st.d[st.n].xend = i + 1;
        st.d[st.n].depth = s_depth + 1;
        st.n++;
      }
    }
  }
}

//
// File trailer for introsort.cpp
//
// [EOF]
//
