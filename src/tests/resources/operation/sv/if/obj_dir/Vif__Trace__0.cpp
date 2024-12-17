// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vif__Syms.h"


void Vif___024root__trace_chg_0_sub_0(Vif___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vif___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vif___024root__trace_chg_0\n"); );
    // Init
    Vif___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vif___024root*>(voidSelf);
    Vif__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vif___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vif___024root__trace_chg_0_sub_0(Vif___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vif__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vif___024root__trace_chg_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    bufp->chgBit(oldp+0,(vlSelf->clk));
    bufp->chgCData(oldp+1,(vlSelf->a),8);
    bufp->chgCData(oldp+2,(vlSelf->b),8);
    bufp->chgCData(oldp+3,(vlSelf->res),8);
}

void Vif___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vif___024root__trace_cleanup\n"); );
    // Init
    Vif___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vif___024root*>(voidSelf);
    Vif__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VlUnpacked<CData/*0:0*/, 1> __Vm_traceActivity;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        __Vm_traceActivity[__Vi0] = 0;
    }
    // Body
    vlSymsp->__Vm_activity = false;
    __Vm_traceActivity[0U] = 0U;
}
