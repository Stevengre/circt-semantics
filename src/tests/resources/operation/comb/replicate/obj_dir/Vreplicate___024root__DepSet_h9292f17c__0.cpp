// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vreplicate.h for the primary calling header

#include "Vreplicate__pch.h"
#include "Vreplicate__Syms.h"
#include "Vreplicate___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vreplicate___024root___dump_triggers__ico(Vreplicate___024root* vlSelf);
#endif  // VL_DEBUG

void Vreplicate___024root___eval_triggers__ico(Vreplicate___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vreplicate__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vreplicate___024root___eval_triggers__ico\n"); );
    // Body
    vlSelf->__VicoTriggered.set(0U, (IData)(vlSelf->__VicoFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vreplicate___024root___dump_triggers__ico(vlSelf);
    }
#endif
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vreplicate___024root___dump_triggers__act(Vreplicate___024root* vlSelf);
#endif  // VL_DEBUG

void Vreplicate___024root___eval_triggers__act(Vreplicate___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vreplicate__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vreplicate___024root___eval_triggers__act\n"); );
    // Body
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vreplicate___024root___dump_triggers__act(vlSelf);
    }
#endif
}
