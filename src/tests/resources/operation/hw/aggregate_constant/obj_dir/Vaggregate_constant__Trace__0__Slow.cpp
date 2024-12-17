// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vaggregate_constant__Syms.h"


VL_ATTR_COLD void Vaggregate_constant___024root__trace_init_sub__TOP__0(Vaggregate_constant___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBus(c+1,0,"res",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 5,0);
    tracep->pushPrefix("Foo", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+1,0,"res",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 5,0);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vaggregate_constant___024root__trace_init_top(Vaggregate_constant___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root__trace_init_top\n"); );
    // Body
    Vaggregate_constant___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vaggregate_constant___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vaggregate_constant___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vaggregate_constant___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vaggregate_constant___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vaggregate_constant___024root__trace_register(Vaggregate_constant___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root__trace_register\n"); );
    // Body
    tracep->addConstCb(&Vaggregate_constant___024root__trace_const_0, 0U, vlSelf);
    tracep->addFullCb(&Vaggregate_constant___024root__trace_full_0, 0U, vlSelf);
    tracep->addChgCb(&Vaggregate_constant___024root__trace_chg_0, 0U, vlSelf);
    tracep->addCleanupCb(&Vaggregate_constant___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vaggregate_constant___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root__trace_const_0\n"); );
    // Init
    Vaggregate_constant___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vaggregate_constant___024root*>(voidSelf);
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
}

VL_ATTR_COLD void Vaggregate_constant___024root__trace_full_0_sub_0(Vaggregate_constant___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vaggregate_constant___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root__trace_full_0\n"); );
    // Init
    Vaggregate_constant___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vaggregate_constant___024root*>(voidSelf);
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vaggregate_constant___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vaggregate_constant___024root__trace_full_0_sub_0(Vaggregate_constant___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant___024root__trace_full_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullCData(oldp+1,(vlSelf->res),6);
}
