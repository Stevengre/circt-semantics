// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vfirmem_x__Syms.h"


//======================

void Vfirmem_x::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vfirmem_x::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vfirmem_x__Syms* __restrict vlSymsp = static_cast<Vfirmem_x__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vfirmem_x::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vfirmem_x::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vfirmem_x__Syms* __restrict vlSymsp = static_cast<Vfirmem_x__Syms*>(userp);
    Vfirmem_x* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vfirmem_x::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vfirmem_x__Syms* __restrict vlSymsp = static_cast<Vfirmem_x__Syms*>(userp);
    Vfirmem_x* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBit(c+7,"clk", false,-1);
        tracep->declBus(c+8,"data_in_w", false,-1, 7,0);
        tracep->declBus(c+9,"data_in_rw", false,-1, 7,0);
        tracep->declBus(c+10,"addr_r", false,-1, 1,0);
        tracep->declBus(c+11,"addr_w", false,-1, 1,0);
        tracep->declBus(c+12,"addr_rw", false,-1, 1,0);
        tracep->declBit(c+13,"mode", false,-1);
        tracep->declBit(c+14,"enable_r", false,-1);
        tracep->declBit(c+15,"enable_w", false,-1);
        tracep->declBit(c+16,"enable_rw", false,-1);
        tracep->declBus(c+17,"read_out", false,-1, 7,0);
        tracep->declBus(c+18,"add_out", false,-1, 7,0);
        tracep->declBit(c+7,"Foo clk", false,-1);
        tracep->declBus(c+8,"Foo data_in_w", false,-1, 7,0);
        tracep->declBus(c+9,"Foo data_in_rw", false,-1, 7,0);
        tracep->declBus(c+10,"Foo addr_r", false,-1, 1,0);
        tracep->declBus(c+11,"Foo addr_w", false,-1, 1,0);
        tracep->declBus(c+12,"Foo addr_rw", false,-1, 1,0);
        tracep->declBit(c+13,"Foo mode", false,-1);
        tracep->declBit(c+14,"Foo enable_r", false,-1);
        tracep->declBit(c+15,"Foo enable_w", false,-1);
        tracep->declBit(c+16,"Foo enable_rw", false,-1);
        tracep->declBus(c+17,"Foo read_out", false,-1, 7,0);
        tracep->declBus(c+18,"Foo add_out", false,-1, 7,0);
        tracep->declBus(c+10,"Foo memory_ext R0_addr", false,-1, 1,0);
        tracep->declBit(c+14,"Foo memory_ext R0_en", false,-1);
        tracep->declBit(c+7,"Foo memory_ext R0_clk", false,-1);
        tracep->declBus(c+1,"Foo memory_ext R0_data", false,-1, 7,0);
        tracep->declBus(c+11,"Foo memory_ext W0_addr", false,-1, 1,0);
        tracep->declBit(c+15,"Foo memory_ext W0_en", false,-1);
        tracep->declBit(c+7,"Foo memory_ext W0_clk", false,-1);
        tracep->declBus(c+2,"Foo memory_ext W0_data", false,-1, 7,0);
        {int i; for (i=0; i<4; i++) {
                tracep->declBus(c+3+i*1,"Foo memory_ext Memory", true,(i+0), 7,0);}}
    }
}

void Vfirmem_x::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vfirmem_x::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vfirmem_x__Syms* __restrict vlSymsp = static_cast<Vfirmem_x__Syms*>(userp);
    Vfirmem_x* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vfirmem_x::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vfirmem_x__Syms* __restrict vlSymsp = static_cast<Vfirmem_x__Syms*>(userp);
    Vfirmem_x* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->Foo__DOT___memory_ext_R0_data),8);
        tracep->fullCData(oldp+2,((0xffU & ((IData)(2U) 
                                            + (IData)(vlTOPp->Foo__DOT___memory_ext_R0_data)))),8);
        tracep->fullCData(oldp+3,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[0]),8);
        tracep->fullCData(oldp+4,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[1]),8);
        tracep->fullCData(oldp+5,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[2]),8);
        tracep->fullCData(oldp+6,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[3]),8);
        tracep->fullBit(oldp+7,(vlTOPp->clk));
        tracep->fullCData(oldp+8,(vlTOPp->data_in_w),8);
        tracep->fullCData(oldp+9,(vlTOPp->data_in_rw),8);
        tracep->fullCData(oldp+10,(vlTOPp->addr_r),2);
        tracep->fullCData(oldp+11,(vlTOPp->addr_w),2);
        tracep->fullCData(oldp+12,(vlTOPp->addr_rw),2);
        tracep->fullBit(oldp+13,(vlTOPp->mode));
        tracep->fullBit(oldp+14,(vlTOPp->enable_r));
        tracep->fullBit(oldp+15,(vlTOPp->enable_w));
        tracep->fullBit(oldp+16,(vlTOPp->enable_rw));
        tracep->fullCData(oldp+17,(vlTOPp->read_out),8);
        tracep->fullCData(oldp+18,(vlTOPp->add_out),8);
    }
}
