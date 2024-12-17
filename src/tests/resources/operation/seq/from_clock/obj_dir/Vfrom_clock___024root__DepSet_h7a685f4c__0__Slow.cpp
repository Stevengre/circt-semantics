// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfrom_clock.h for the primary calling header

#include "Vfrom_clock__pch.h"
#include "Vfrom_clock__Syms.h"
#include "Vfrom_clock___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfrom_clock___024root___dump_triggers__stl(Vfrom_clock___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vfrom_clock___024root___eval_triggers__stl(Vfrom_clock___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfrom_clock__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfrom_clock___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfrom_clock___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
