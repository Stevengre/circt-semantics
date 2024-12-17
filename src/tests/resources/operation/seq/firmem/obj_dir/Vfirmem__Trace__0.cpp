// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vfirmem__Syms.h"


void Vfirmem___024root__trace_chg_0_sub_0(Vfirmem___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vfirmem___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root__trace_chg_0\n"); );
    // Init
    Vfirmem___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfirmem___024root*>(voidSelf);
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vfirmem___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vfirmem___024root__trace_chg_0_sub_0(Vfirmem___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root__trace_chg_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[1U])) {
        bufp->chgCData(oldp+0,(vlSelf->Foo__DOT__memory_ext__DOT__Memory[0]),8);
        bufp->chgCData(oldp+1,(vlSelf->Foo__DOT__memory_ext__DOT__Memory[1]),8);
        bufp->chgCData(oldp+2,(vlSelf->Foo__DOT__memory_ext__DOT__Memory[2]),8);
        bufp->chgCData(oldp+3,(vlSelf->Foo__DOT__memory_ext__DOT__Memory[3]),8);
    }
    bufp->chgBit(oldp+4,(vlSelf->clk));
    bufp->chgCData(oldp+5,(vlSelf->data_in_w),8);
    bufp->chgCData(oldp+6,(vlSelf->data_in_rw),8);
    bufp->chgCData(oldp+7,(vlSelf->addr_r),2);
    bufp->chgCData(oldp+8,(vlSelf->addr_w),2);
    bufp->chgCData(oldp+9,(vlSelf->addr_rw),2);
    bufp->chgBit(oldp+10,(vlSelf->mode));
    bufp->chgBit(oldp+11,(vlSelf->enable_r));
    bufp->chgBit(oldp+12,(vlSelf->enable_w));
    bufp->chgBit(oldp+13,(vlSelf->enable_rw));
    bufp->chgCData(oldp+14,(vlSelf->read_out),8);
}

void Vfirmem___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root__trace_cleanup\n"); );
    // Init
    Vfirmem___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfirmem___024root*>(voidSelf);
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
}
