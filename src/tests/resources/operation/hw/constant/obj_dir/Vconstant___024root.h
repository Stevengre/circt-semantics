// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vconstant.h for the primary calling header

#ifndef VERILATED_VCONSTANT___024ROOT_H_
#define VERILATED_VCONSTANT___024ROOT_H_  // guard

#include "verilated.h"


class Vconstant__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vconstant___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(a,7,0);
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
    Vconstant__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vconstant___024root(Vconstant__Syms* symsp, const char* v__name);
    ~Vconstant___024root();
    VL_UNCOPYABLE(Vconstant___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
