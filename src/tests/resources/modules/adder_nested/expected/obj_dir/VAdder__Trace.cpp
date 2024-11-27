// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VAdder__Syms.h"


void VAdder::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    VAdder__Syms* __restrict vlSymsp = static_cast<VAdder__Syms*>(userp);
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void VAdder::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    VAdder__Syms* __restrict vlSymsp = static_cast<VAdder__Syms*>(userp);
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->chgCData(oldp+0,(vlTOPp->io_a),8);
        tracep->chgCData(oldp+1,(vlTOPp->res_out2),8);
        tracep->chgCData(oldp+2,(vlTOPp->res_out1),8);
        tracep->chgCData(oldp+3,((0xffU & ((IData)(2U) 
                                           + (IData)(vlTOPp->io_a)))),8);
        tracep->chgCData(oldp+4,((0xffU & ((IData)(1U) 
                                           + (IData)(vlTOPp->io_a)))),8);
    }
}

void VAdder::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    VAdder__Syms* __restrict vlSymsp = static_cast<VAdder__Syms*>(userp);
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
    }
}
