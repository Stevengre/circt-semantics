// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vfirmem_mask__Syms.h"


void Vfirmem_mask___024root__trace_chg_0_sub_0(Vfirmem_mask___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vfirmem_mask___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root__trace_chg_0\n"); );
    // Init
    Vfirmem_mask___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfirmem_mask___024root*>(voidSelf);
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vfirmem_mask___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vfirmem_mask___024root__trace_chg_0_sub_0(Vfirmem_mask___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root__trace_chg_0_sub_0\n"); );
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[1U]))) {
        bufp->chgCData(oldp+0,(vlSelfRef.Foo__DOT__memory_ext__DOT__Memory[0]),8);
        bufp->chgCData(oldp+1,(vlSelfRef.Foo__DOT__memory_ext__DOT__Memory[1]),8);
        bufp->chgCData(oldp+2,(vlSelfRef.Foo__DOT__memory_ext__DOT__Memory[2]),8);
        bufp->chgCData(oldp+3,(vlSelfRef.Foo__DOT__memory_ext__DOT__Memory[3]),8);
    }
    bufp->chgBit(oldp+4,(vlSelfRef.clk));
    bufp->chgCData(oldp+5,(vlSelfRef.data_in_w),8);
    bufp->chgCData(oldp+6,(vlSelfRef.data_in_rw),8);
    bufp->chgCData(oldp+7,(vlSelfRef.addr_r),2);
    bufp->chgCData(oldp+8,(vlSelfRef.addr_w),2);
    bufp->chgCData(oldp+9,(vlSelfRef.addr_rw),2);
    bufp->chgBit(oldp+10,(vlSelfRef.mode));
    bufp->chgBit(oldp+11,(vlSelfRef.enable_r));
    bufp->chgBit(oldp+12,(vlSelfRef.enable_w));
    bufp->chgBit(oldp+13,(vlSelfRef.enable_rw));
    bufp->chgCData(oldp+14,(vlSelfRef.mask_in),2);
    bufp->chgCData(oldp+15,(vlSelfRef.rw_out),8);
}

void Vfirmem_mask___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root__trace_cleanup\n"); );
    // Init
    Vfirmem_mask___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfirmem_mask___024root*>(voidSelf);
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
}
