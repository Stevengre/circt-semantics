// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vif.h for the primary calling header

#include "Vif__pch.h"
#include "Vif__Syms.h"
#include "Vif___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vif___024root___dump_triggers__stl(Vif___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vif___024root___eval_triggers__stl(Vif___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vif__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vif___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vif___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
