// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirreg.h for the primary calling header

#include "Vfirreg__pch.h"
#include "Vfirreg__Syms.h"
#include "Vfirreg___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirreg___024root___dump_triggers__act(Vfirreg___024root* vlSelf);
#endif  // VL_DEBUG

void Vfirreg___024root___eval_triggers__act(Vfirreg___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirreg___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfirreg___024root___dump_triggers__act(vlSelf);
    }
#endif
}
