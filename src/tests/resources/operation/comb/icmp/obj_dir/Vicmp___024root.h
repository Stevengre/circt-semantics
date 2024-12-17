// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vicmp.h for the primary calling header

#ifndef VERILATED_VICMP___024ROOT_H_
#define VERILATED_VICMP___024ROOT_H_  // guard

#include "verilated.h"


class Vicmp__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vicmp___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(a,7,0);
    VL_IN8(b,7,0);
    VL_OUT8(res,0,0);
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vicmp__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vicmp___024root(Vicmp__Syms* symsp, const char* v__name);
    ~Vicmp___024root();
    VL_UNCOPYABLE(Vicmp___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
