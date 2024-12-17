// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vfrom_clock__Syms.h"


VL_ATTR_COLD void Vfrom_clock___024root__trace_init_sub__TOP__0(Vfrom_clock___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfrom_clock__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfrom_clock___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBit(c+1,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"res",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("Foo", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+1,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"res",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vfrom_clock___024root__trace_init_top(Vfrom_clock___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfrom_clock__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfrom_clock___024root__trace_init_top\n"); );
    // Body
    Vfrom_clock___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vfrom_clock___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vfrom_clock___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vfrom_clock___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vfrom_clock___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vfrom_clock___024root__trace_register(Vfrom_clock___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfrom_clock__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfrom_clock___024root__trace_register\n"); );
    // Body
    tracep->addConstCb(&Vfrom_clock___024root__trace_const_0, 0U, vlSelf);
    tracep->addFullCb(&Vfrom_clock___024root__trace_full_0, 0U, vlSelf);
    tracep->addChgCb(&Vfrom_clock___024root__trace_chg_0, 0U, vlSelf);
    tracep->addCleanupCb(&Vfrom_clock___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vfrom_clock___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfrom_clock___024root__trace_const_0\n"); );
    // Init
    Vfrom_clock___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfrom_clock___024root*>(voidSelf);
    Vfrom_clock__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
}

VL_ATTR_COLD void Vfrom_clock___024root__trace_full_0_sub_0(Vfrom_clock___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vfrom_clock___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfrom_clock___024root__trace_full_0\n"); );
    // Init
    Vfrom_clock___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfrom_clock___024root*>(voidSelf);
    Vfrom_clock__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vfrom_clock___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vfrom_clock___024root__trace_full_0_sub_0(Vfrom_clock___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfrom_clock__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfrom_clock___024root__trace_full_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullBit(oldp+1,(vlSelf->clk));
    bufp->fullBit(oldp+2,(vlSelf->res));
}
