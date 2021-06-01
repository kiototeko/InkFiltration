//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
// File: heapsort.cpp
//
// MATLAB Coder version            : 5.0
// C/C++ source code generated on  : 07-May-2021 23:24:34
//

// Include Files
#include "heapsort.h"
#include "getPeaksA.h"
#include "getPeaksGlobal_data.h"
#include "getPeaksPre.h"
#include "rt_nonfinite.h"

// Function Declarations
static void heapify(int x[34], int idx, int xstart, int xend);

// Function Definitions

//
// Arguments    : int x[34]
//                int idx
//                int xstart
//                int xend
// Return Type  : void
//
static void heapify(int x[34], int idx, int xstart, int xend)
{
  boolean_T changed;
  int extremumIdx;
  int leftIdx;
  boolean_T exitg1;
  int extremum;
  int ai;
  int aj;
  changed = true;
  extremumIdx = (idx + xstart) - 2;
  leftIdx = ((idx << 1) + xstart) - 2;
  exitg1 = false;
  while ((!exitg1) && (leftIdx + 1 < xend)) {
    int cmpIdx;
    int xcmp;
    changed = false;
    extremum = x[extremumIdx];
    cmpIdx = leftIdx;
    xcmp = x[leftIdx];
    ai = iv[x[leftIdx] - 1];
    aj = x[leftIdx + 1] - 1;
    if ((ai < iv[aj]) || ((ai == iv[aj]) && (iv1[x[leftIdx] - 1] < iv1[aj]))) {
      cmpIdx = leftIdx + 1;
      xcmp = x[leftIdx + 1];
    }

    ai = iv[x[extremumIdx] - 1];
    aj = iv[xcmp - 1];
    if ((ai < aj) || ((ai == aj) && (iv1[x[extremumIdx] - 1] < iv1[xcmp - 1])))
    {
      x[extremumIdx] = xcmp;
      x[cmpIdx] = extremum;
      extremumIdx = cmpIdx;
      leftIdx = ((((cmpIdx - xstart) + 2) << 1) + xstart) - 2;
      changed = true;
    } else {
      exitg1 = true;
    }
  }

  if (changed && (leftIdx + 1 <= xend)) {
    extremum = x[extremumIdx];
    ai = iv[x[extremumIdx] - 1];
    aj = iv[x[leftIdx] - 1];
    if ((ai < aj) || ((ai == aj) && (iv1[x[extremumIdx] - 1] < iv1[x[leftIdx] -
          1]))) {
      x[extremumIdx] = x[leftIdx];
      x[leftIdx] = extremum;
    }
  }
}

//
// Arguments    : int x[34]
//                int xstart
//                int xend
// Return Type  : void
//
void b_heapsort(int x[34], int xstart, int xend)
{
  int n;
  int t;
  n = (xend - xstart) - 1;
  for (t = n + 2; t >= 1; t--) {
    heapify(x, t, xstart, xend);
  }

  for (int k = 0; k <= n; k++) {
    t = x[xend - 1];
    x[xend - 1] = x[xstart - 1];
    x[xstart - 1] = t;
    xend--;
    heapify(x, 1, xstart, xend);
  }
}

//
// File trailer for heapsort.cpp
//
// [EOF]
//
