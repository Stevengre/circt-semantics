// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem_mask.h for the primary calling header

#include "Vfirmem_mask__pch.h"
#include "Vfirmem_mask__Syms.h"
#include "Vfirmem_mask___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem_mask___024root___dump_triggers__act(Vfirmem_mask___024root* vlSelf);
#endif  // VL_DEBUG

void Vfirmem_mask___024root___eval_triggers__act(Vfirmem_mask___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root___eval_triggers__act\n"); );
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered.setBit(0U, ((IData)(vlSelfRef.clk) 
                                          & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__clk__0))));
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vfirmem_mask___024root___dump_triggers__act(vlSelf);
    }
#endif
}
