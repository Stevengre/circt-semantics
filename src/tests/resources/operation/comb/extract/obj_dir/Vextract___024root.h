// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vextract.h for the primary calling header

#ifndef VERILATED_VEXTRACT___024ROOT_H_
#define VERILATED_VEXTRACT___024ROOT_H_  // guard

#include "verilated.h"


class Vextract__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vextract___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(a,7,0);
    VL_OUT8(res,3,0);
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vextract__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vextract___024root(Vextract__Syms* symsp, const char* v__name);
    ~Vextract___024root();
    VL_UNCOPYABLE(Vextract___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
