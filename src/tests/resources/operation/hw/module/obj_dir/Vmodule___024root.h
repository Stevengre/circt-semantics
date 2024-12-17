// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vmodule.h for the primary calling header

#ifndef VERILATED_VMODULE___024ROOT_H_
#define VERILATED_VMODULE___024ROOT_H_  // guard

#include "verilated.h"


class Vmodule__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vmodule___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(a,7,0);
    VL_IN8(b,7,0);
    VL_OUT8(res,7,0);
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vmodule__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vmodule___024root(Vmodule__Syms* symsp, const char* v__name);
    ~Vmodule___024root();
    VL_UNCOPYABLE(Vmodule___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
