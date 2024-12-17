// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vinfo.h for the primary calling header

#include "Vinfo__pch.h"
#include "Vinfo__Syms.h"
#include "Vinfo___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vinfo___024root___dump_triggers__stl(Vinfo___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vinfo___024root___eval_triggers__stl(Vinfo___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vinfo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vinfo___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vinfo___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
