// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem_rw.h for the primary calling header

#include "Vfirmem_rw__pch.h"
#include "Vfirmem_rw__Syms.h"
#include "Vfirmem_rw___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem_rw___024root___dump_triggers__ico(Vfirmem_rw___024root* vlSelf);
#endif  // VL_DEBUG

void Vfirmem_rw___024root___eval_triggers__ico(Vfirmem_rw___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem_rw__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rw___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfirmem_rw___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem_rw___024root___dump_triggers__act(Vfirmem_rw___024root* vlSelf);
#endif  // VL_DEBUG

void Vfirmem_rw___024root___eval_triggers__act(Vfirmem_rw___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem_rw__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rw___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfirmem_rw___024root___dump_triggers__act(vlSelf);
    }
#endif
}
