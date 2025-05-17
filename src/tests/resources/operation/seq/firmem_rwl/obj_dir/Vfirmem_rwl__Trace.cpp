// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vfirmem_rwl__Syms.h"


void Vfirmem_rwl::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    Vfirmem_rwl__Syms* __restrict vlSymsp = static_cast<Vfirmem_rwl__Syms*>(userp);
    Vfirmem_rwl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void Vfirmem_rwl::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    Vfirmem_rwl__Syms* __restrict vlSymsp = static_cast<Vfirmem_rwl__Syms*>(userp);
    Vfirmem_rwl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        if (VL_UNLIKELY(vlTOPp->__Vm_traceActivity[1U])) {
            tracep->chgCData(oldp+0,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[0]),8);
            tracep->chgCData(oldp+1,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[1]),8);
            tracep->chgCData(oldp+2,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[2]),8);
            tracep->chgCData(oldp+3,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[3]),8);
        }
        tracep->chgBit(oldp+4,(vlTOPp->clk));
        tracep->chgCData(oldp+5,(vlTOPp->data_in_w),8);
        tracep->chgCData(oldp+6,(vlTOPp->data_in_rw),8);
        tracep->chgCData(oldp+7,(vlTOPp->addr_r),2);
        tracep->chgCData(oldp+8,(vlTOPp->addr_w),2);
        tracep->chgCData(oldp+9,(vlTOPp->addr_rw),2);
        tracep->chgBit(oldp+10,(vlTOPp->mode));
        tracep->chgBit(oldp+11,(vlTOPp->enable_r));
        tracep->chgBit(oldp+12,(vlTOPp->enable_w));
        tracep->chgBit(oldp+13,(vlTOPp->enable_rw));
        tracep->chgCData(oldp+14,(vlTOPp->read_out),8);
        tracep->chgCData(oldp+15,(vlTOPp->rw_out),8);
    }
}

void Vfirmem_rwl::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    Vfirmem_rwl__Syms* __restrict vlSymsp = static_cast<Vfirmem_rwl__Syms*>(userp);
    Vfirmem_rwl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
        vlTOPp->__Vm_traceActivity[1U] = 0U;
    }
}
