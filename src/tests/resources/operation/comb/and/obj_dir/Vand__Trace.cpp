// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vand__Syms.h"


void Vand::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    Vand__Syms* __restrict vlSymsp = static_cast<Vand__Syms*>(userp);
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void Vand::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    Vand__Syms* __restrict vlSymsp = static_cast<Vand__Syms*>(userp);
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->chgCData(oldp+0,(vlTOPp->a),8);
        tracep->chgCData(oldp+1,(vlTOPp->b),8);
        tracep->chgCData(oldp+2,(vlTOPp->res),8);
    }
}

void Vand::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    Vand__Syms* __restrict vlSymsp = static_cast<Vand__Syms*>(userp);
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
    }
}
