// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Varray_get.h for the primary calling header

#include "Varray_get__pch.h"
#include "Varray_get__Syms.h"
#include "Varray_get___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Varray_get___024root___dump_triggers__stl(Varray_get___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Varray_get___024root___eval_triggers__stl(Varray_get___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Varray_get___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
