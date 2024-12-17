// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Valways.h for the primary calling header

#ifndef VERILATED_VALWAYS___024ROOT_H_
#define VERILATED_VALWAYS___024ROOT_H_  // guard

#include "verilated.h"


class Valways__Syms;

class alignas(VL_CACHE_LINE_BYTES) Valways___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(a,7,0);
    VL_IN8(b,7,0);
    VL_OUT8(result,7,0);
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<1> __VactTriggered;
    VlTriggerVec<1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Valways__Syms* const vlSymsp;

    // CONSTRUCTORS
    Valways___024root(Valways__Syms* symsp, const char* v__name);
    ~Valways___024root();
    VL_UNCOPYABLE(Valways___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
