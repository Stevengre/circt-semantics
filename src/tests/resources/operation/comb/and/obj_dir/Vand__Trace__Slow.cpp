// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vand__Syms.h"


//======================

void Vand::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vand::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vand__Syms* __restrict vlSymsp = static_cast<Vand__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vand::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vand::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vand__Syms* __restrict vlSymsp = static_cast<Vand__Syms*>(userp);
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vand::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vand__Syms* __restrict vlSymsp = static_cast<Vand__Syms*>(userp);
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
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

void Vand::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vand::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vand__Syms* __restrict vlSymsp = static_cast<Vand__Syms*>(userp);
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vand::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vand__Syms* __restrict vlSymsp = static_cast<Vand__Syms*>(userp);
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->a),8);
        tracep->fullCData(oldp+2,(vlTOPp->b),8);
        tracep->fullCData(oldp+3,(vlTOPp->res),8);
    }
}
