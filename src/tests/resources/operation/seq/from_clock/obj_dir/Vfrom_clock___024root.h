// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vfrom_clock.h for the primary calling header

#ifndef VERILATED_VFROM_CLOCK___024ROOT_H_
#define VERILATED_VFROM_CLOCK___024ROOT_H_  // guard

#include "verilated.h"


class Vfrom_clock__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vfrom_clock___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
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
    Vfrom_clock__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vfrom_clock___024root(Vfrom_clock__Syms* symsp, const char* v__name);
    ~Vfrom_clock___024root();
    VL_UNCOPYABLE(Vfrom_clock___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
