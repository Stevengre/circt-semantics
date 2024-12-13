// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vfirmem.h for the primary calling header

#ifndef VERILATED_VFIRMEM___024ROOT_H_
#define VERILATED_VFIRMEM___024ROOT_H_  // guard

#include "verilated.h"


class Vfirmem__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vfirmem___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(reset,0,0);
    VL_IN8(data_in,7,0);
    VL_IN8(addr,1,0);
    VL_IN8(mode,0,0);
    VL_OUT8(read_out,7,0);
    VL_OUT8(rw_out,7,0);
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<CData/*7:0*/, 4> Foo__DOT__memory_ext__DOT__Memory;
    VlUnpacked<CData/*0:0*/, 2> __Vm_traceActivity;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<1> __VactTriggered;
    VlTriggerVec<1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vfirmem__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vfirmem___024root(Vfirmem__Syms* symsp, const char* v__name);
    ~Vfirmem___024root();
    VL_UNCOPYABLE(Vfirmem___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
