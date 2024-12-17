// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vif.h for the primary calling header

#ifndef VERILATED_VIF___024ROOT_H_
#define VERILATED_VIF___024ROOT_H_  // guard

#include "verilated.h"


class Vif__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vif___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(a,7,0);
    VL_IN8(b,7,0);
    VL_OUT8(res,7,0);
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
    Vif__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vif___024root(Vif__Syms* symsp, const char* v__name);
    ~Vif___024root();
    VL_UNCOPYABLE(Vif___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
