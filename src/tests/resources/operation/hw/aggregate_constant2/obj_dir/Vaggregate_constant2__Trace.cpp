// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vaggregate_constant2__Syms.h"


void Vaggregate_constant2::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    Vaggregate_constant2__Syms* __restrict vlSymsp = static_cast<Vaggregate_constant2__Syms*>(userp);
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void Vaggregate_constant2::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    Vaggregate_constant2__Syms* __restrict vlSymsp = static_cast<Vaggregate_constant2__Syms*>(userp);
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->chgCData(oldp+0,(vlTOPp->a),2);
        tracep->chgCData(oldp+1,(vlTOPp->b),8);
        tracep->chgCData(oldp+2,(vlTOPp->res),8);
    }
}

void Vaggregate_constant2::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    Vaggregate_constant2__Syms* __restrict vlSymsp = static_cast<Vaggregate_constant2__Syms*>(userp);
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
    }
}
