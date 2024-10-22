// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vadd__Syms.h"


//======================

void Vadd::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vadd::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vadd__Syms* __restrict vlSymsp = static_cast<Vadd__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vadd::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vadd::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vadd__Syms* __restrict vlSymsp = static_cast<Vadd__Syms*>(userp);
    Vadd* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vadd::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vadd__Syms* __restrict vlSymsp = static_cast<Vadd__Syms*>(userp);
    Vadd* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBus(c+1,"a", false,-1, 7,0);
        tracep->declBus(c+2,"b", false,-1, 7,0);
        tracep->declBus(c+3,"res", false,-1, 7,0);
        tracep->declBus(c+1,"Foo a", false,-1, 7,0);
        tracep->declBus(c+2,"Foo b", false,-1, 7,0);
        tracep->declBus(c+3,"Foo res", false,-1, 7,0);
    }
}

void Vadd::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vadd::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vadd__Syms* __restrict vlSymsp = static_cast<Vadd__Syms*>(userp);
    Vadd* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vadd::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vadd__Syms* __restrict vlSymsp = static_cast<Vadd__Syms*>(userp);
    Vadd* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->a),8);
        tracep->fullCData(oldp+2,(vlTOPp->b),8);
        tracep->fullCData(oldp+3,(vlTOPp->res),8);
    }
}
