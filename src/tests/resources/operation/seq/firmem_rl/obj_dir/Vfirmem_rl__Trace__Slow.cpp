// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vfirmem_rl__Syms.h"


//======================

void Vfirmem_rl::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vfirmem_rl::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vfirmem_rl__Syms* __restrict vlSymsp = static_cast<Vfirmem_rl__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vfirmem_rl::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vfirmem_rl::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vfirmem_rl__Syms* __restrict vlSymsp = static_cast<Vfirmem_rl__Syms*>(userp);
    Vfirmem_rl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vfirmem_rl::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vfirmem_rl__Syms* __restrict vlSymsp = static_cast<Vfirmem_rl__Syms*>(userp);
    Vfirmem_rl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBit(c+5,"clk", false,-1);
        tracep->declBus(c+6,"data_in_w", false,-1, 7,0);
        tracep->declBus(c+7,"data_in_rw", false,-1, 7,0);
        tracep->declBus(c+8,"addr_r", false,-1, 1,0);
        tracep->declBus(c+9,"addr_w", false,-1, 1,0);
        tracep->declBus(c+10,"addr_rw", false,-1, 1,0);
        tracep->declBit(c+11,"mode", false,-1);
        tracep->declBit(c+12,"enable_r", false,-1);
        tracep->declBit(c+13,"enable_w", false,-1);
        tracep->declBit(c+14,"enable_rw", false,-1);
        tracep->declBus(c+15,"read_out", false,-1, 7,0);
        tracep->declBit(c+5,"Foo clk", false,-1);
        tracep->declBus(c+6,"Foo data_in_w", false,-1, 7,0);
        tracep->declBus(c+7,"Foo data_in_rw", false,-1, 7,0);
        tracep->declBus(c+8,"Foo addr_r", false,-1, 1,0);
        tracep->declBus(c+9,"Foo addr_w", false,-1, 1,0);
        tracep->declBus(c+10,"Foo addr_rw", false,-1, 1,0);
        tracep->declBit(c+11,"Foo mode", false,-1);
        tracep->declBit(c+12,"Foo enable_r", false,-1);
        tracep->declBit(c+13,"Foo enable_w", false,-1);
        tracep->declBit(c+14,"Foo enable_rw", false,-1);
        tracep->declBus(c+15,"Foo read_out", false,-1, 7,0);
        tracep->declBus(c+8,"Foo memory_ext R0_addr", false,-1, 1,0);
        tracep->declBit(c+12,"Foo memory_ext R0_en", false,-1);
        tracep->declBit(c+5,"Foo memory_ext R0_clk", false,-1);
        tracep->declBus(c+15,"Foo memory_ext R0_data", false,-1, 7,0);
        tracep->declBus(c+9,"Foo memory_ext W0_addr", false,-1, 1,0);
        tracep->declBit(c+13,"Foo memory_ext W0_en", false,-1);
        tracep->declBit(c+5,"Foo memory_ext W0_clk", false,-1);
        tracep->declBus(c+6,"Foo memory_ext W0_data", false,-1, 7,0);
        {int i; for (i=0; i<4; i++) {
                tracep->declBus(c+1+i*1,"Foo memory_ext Memory", true,(i+0), 7,0);}}
    }
}

void Vfirmem_rl::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vfirmem_rl::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vfirmem_rl__Syms* __restrict vlSymsp = static_cast<Vfirmem_rl__Syms*>(userp);
    Vfirmem_rl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vfirmem_rl::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vfirmem_rl__Syms* __restrict vlSymsp = static_cast<Vfirmem_rl__Syms*>(userp);
    Vfirmem_rl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[0]),8);
        tracep->fullCData(oldp+2,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[1]),8);
        tracep->fullCData(oldp+3,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[2]),8);
        tracep->fullCData(oldp+4,(vlTOPp->Foo__DOT__memory_ext__DOT__Memory[3]),8);
        tracep->fullBit(oldp+5,(vlTOPp->clk));
        tracep->fullCData(oldp+6,(vlTOPp->data_in_w),8);
        tracep->fullCData(oldp+7,(vlTOPp->data_in_rw),8);
        tracep->fullCData(oldp+8,(vlTOPp->addr_r),2);
        tracep->fullCData(oldp+9,(vlTOPp->addr_w),2);
        tracep->fullCData(oldp+10,(vlTOPp->addr_rw),2);
        tracep->fullBit(oldp+11,(vlTOPp->mode));
        tracep->fullBit(oldp+12,(vlTOPp->enable_r));
        tracep->fullBit(oldp+13,(vlTOPp->enable_w));
        tracep->fullBit(oldp+14,(vlTOPp->enable_rw));
        tracep->fullCData(oldp+15,(vlTOPp->read_out),8);
    }
}
