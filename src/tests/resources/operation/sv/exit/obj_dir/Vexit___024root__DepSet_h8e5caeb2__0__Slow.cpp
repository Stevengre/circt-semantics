// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vexit.h for the primary calling header

#include "Vexit__pch.h"
#include "Vexit__Syms.h"
#include "Vexit___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vexit___024root___dump_triggers__stl(Vexit___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vexit___024root___eval_triggers__stl(Vexit___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vexit__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vexit___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vexit___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
