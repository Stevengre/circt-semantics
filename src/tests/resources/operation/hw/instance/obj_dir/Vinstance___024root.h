// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vinstance.h for the primary calling header

#ifndef VERILATED_VINSTANCE___024ROOT_H_
#define VERILATED_VINSTANCE___024ROOT_H_  // guard

#include "verilated.h"


class Vinstance__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vinstance___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(io_a,7,0);
    VL_OUT8(res_out2,7,0);
    VL_OUT8(res_out1,7,0);
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vinstance__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vinstance___024root(Vinstance__Syms* symsp, const char* v__name);
    ~Vinstance___024root();
    VL_UNCOPYABLE(Vinstance___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
