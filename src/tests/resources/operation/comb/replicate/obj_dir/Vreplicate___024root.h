// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vreplicate.h for the primary calling header

#ifndef VERILATED_VREPLICATE___024ROOT_H_
#define VERILATED_VREPLICATE___024ROOT_H_  // guard

#include "verilated.h"


class Vreplicate__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vreplicate___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(a,7,0);
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
    Vreplicate__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vreplicate___024root(Vreplicate__Syms* symsp, const char* v__name);
    ~Vreplicate___024root();
    VL_UNCOPYABLE(Vreplicate___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
