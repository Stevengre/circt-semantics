// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vaggregate_constant.h for the primary calling header

#ifndef VERILATED_VAGGREGATE_CONSTANT___024ROOT_H_
#define VERILATED_VAGGREGATE_CONSTANT___024ROOT_H_  // guard

#include "verilated.h"


class Vaggregate_constant__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vaggregate_constant___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_OUT8(res,5,0);
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vaggregate_constant__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vaggregate_constant___024root(Vaggregate_constant__Syms* symsp, const char* v__name);
    ~Vaggregate_constant___024root();
    VL_UNCOPYABLE(Vaggregate_constant___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
