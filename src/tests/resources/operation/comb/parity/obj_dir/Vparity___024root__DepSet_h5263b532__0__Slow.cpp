// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vparity.h for the primary calling header

#include "Vparity__pch.h"
#include "Vparity__Syms.h"
#include "Vparity___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vparity___024root___dump_triggers__stl(Vparity___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vparity___024root___eval_triggers__stl(Vparity___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vparity__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vparity___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vparity___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
