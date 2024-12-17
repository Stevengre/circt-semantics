// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Valways.h for the primary calling header

#include "Valways__pch.h"
#include "Valways__Syms.h"
#include "Valways___024root.h"

VL_ATTR_COLD void Valways___024root___eval_initial__TOP(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___eval_initial__TOP\n"); );
    // Body
    VL_WRITEF_NX("[%0t] -Info: always.sv:12: %NFoo: world\n",0,
                 64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name());
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Valways___024root___dump_triggers__stl(Valways___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Valways___024root___eval_triggers__stl(Valways___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valways___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Valways___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
