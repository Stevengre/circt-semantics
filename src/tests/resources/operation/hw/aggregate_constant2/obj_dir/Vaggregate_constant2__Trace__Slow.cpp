// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vaggregate_constant2__Syms.h"


//======================

void Vaggregate_constant2::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vaggregate_constant2::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vaggregate_constant2__Syms* __restrict vlSymsp = static_cast<Vaggregate_constant2__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vaggregate_constant2::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vaggregate_constant2::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vaggregate_constant2__Syms* __restrict vlSymsp = static_cast<Vaggregate_constant2__Syms*>(userp);
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vaggregate_constant2::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vaggregate_constant2__Syms* __restrict vlSymsp = static_cast<Vaggregate_constant2__Syms*>(userp);
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBus(c+1,"a", false,-1, 1,0);
        tracep->declBus(c+2,"b", false,-1, 7,0);
        tracep->declBus(c+3,"res", false,-1, 7,0);
        tracep->declBus(c+1,"Foo a", false,-1, 1,0);
        tracep->declBus(c+2,"Foo b", false,-1, 7,0);
        tracep->declBus(c+3,"Foo res", false,-1, 7,0);
    }
}

void Vaggregate_constant2::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vaggregate_constant2::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vaggregate_constant2__Syms* __restrict vlSymsp = static_cast<Vaggregate_constant2__Syms*>(userp);
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vaggregate_constant2::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vaggregate_constant2__Syms* __restrict vlSymsp = static_cast<Vaggregate_constant2__Syms*>(userp);
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->a),2);
        tracep->fullCData(oldp+2,(vlTOPp->b),8);
        tracep->fullCData(oldp+3,(vlTOPp->res),8);
    }
}
