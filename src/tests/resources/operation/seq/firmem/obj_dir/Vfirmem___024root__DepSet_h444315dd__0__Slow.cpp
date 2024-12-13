// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem.h for the primary calling header

#include "Vfirmem__pch.h"
#include "Vfirmem__Syms.h"
#include "Vfirmem___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem___024root___dump_triggers__stl(Vfirmem___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vfirmem___024root___eval_triggers__stl(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfirmem___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
