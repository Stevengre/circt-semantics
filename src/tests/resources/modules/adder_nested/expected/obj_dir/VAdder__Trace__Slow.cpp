// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VAdder__Syms.h"


//======================

void VAdder::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void VAdder::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    VAdder__Syms* __restrict vlSymsp = static_cast<VAdder__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    VAdder::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void VAdder::traceInitTop(void* userp, VerilatedVcd* tracep) {
    VAdder__Syms* __restrict vlSymsp = static_cast<VAdder__Syms*>(userp);
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void VAdder::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    VAdder__Syms* __restrict vlSymsp = static_cast<VAdder__Syms*>(userp);
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBus(c+1,"io_a", false,-1, 7,0);
        tracep->declBus(c+2,"res_out2", false,-1, 7,0);
        tracep->declBus(c+3,"res_out1", false,-1, 7,0);
        tracep->declBus(c+1,"Adder io_a", false,-1, 7,0);
        tracep->declBus(c+2,"Adder res_out2", false,-1, 7,0);
        tracep->declBus(c+3,"Adder res_out1", false,-1, 7,0);
        tracep->declBus(c+1,"Adder i0 io_a", false,-1, 7,0);
        tracep->declBus(c+4,"Adder i0 res2", false,-1, 7,0);
        tracep->declBus(c+1,"Adder i0 i0 io_a", false,-1, 7,0);
        tracep->declBus(c+5,"Adder i0 i0 res", false,-1, 7,0);
        tracep->declBus(c+5,"Adder i0 i1 io_a", false,-1, 7,0);
        tracep->declBus(c+4,"Adder i0 i1 res", false,-1, 7,0);
        tracep->declBus(c+4,"Adder i2 io_a", false,-1, 7,0);
        tracep->declBus(c+3,"Adder i2 res", false,-1, 7,0);
    }
}

void VAdder::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void VAdder::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    VAdder__Syms* __restrict vlSymsp = static_cast<VAdder__Syms*>(userp);
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void VAdder::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    VAdder__Syms* __restrict vlSymsp = static_cast<VAdder__Syms*>(userp);
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->io_a),8);
        tracep->fullCData(oldp+2,(vlTOPp->res_out2),8);
        tracep->fullCData(oldp+3,(vlTOPp->res_out1),8);
        tracep->fullCData(oldp+4,((0xffU & ((IData)(2U) 
                                            + (IData)(vlTOPp->io_a)))),8);
        tracep->fullCData(oldp+5,((0xffU & ((IData)(1U) 
                                            + (IData)(vlTOPp->io_a)))),8);
    }
}
