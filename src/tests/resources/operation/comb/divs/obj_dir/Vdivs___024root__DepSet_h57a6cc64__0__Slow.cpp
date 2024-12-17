// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vdivs.h for the primary calling header

#include "Vdivs__pch.h"
#include "Vdivs__Syms.h"
#include "Vdivs___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vdivs___024root___dump_triggers__stl(Vdivs___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vdivs___024root___eval_triggers__stl(Vdivs___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vdivs__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdivs___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vdivs___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
