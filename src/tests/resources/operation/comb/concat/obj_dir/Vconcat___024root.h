// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vconcat.h for the primary calling header

#ifndef VERILATED_VCONCAT___024ROOT_H_
#define VERILATED_VCONCAT___024ROOT_H_  // guard

#include "verilated.h"


class Vconcat__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vconcat___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(a,7,0);
    VL_IN8(b,7,0);
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __VactContinue;
    VL_OUT16(res,15,0);
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vconcat__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vconcat___024root(Vconcat__Syms* symsp, const char* v__name);
    ~Vconcat___024root();
    VL_UNCOPYABLE(Vconcat___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
