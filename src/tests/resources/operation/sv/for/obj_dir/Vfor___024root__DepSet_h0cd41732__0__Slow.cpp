// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfor.h for the primary calling header

#include "Vfor__pch.h"
#include "Vfor__Syms.h"
#include "Vfor___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfor___024root___dump_triggers__stl(Vfor___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vfor___024root___eval_triggers__stl(Vfor___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfor__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfor___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfor___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
