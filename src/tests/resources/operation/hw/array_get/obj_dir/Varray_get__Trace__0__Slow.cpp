// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Varray_get__Syms.h"


VL_ATTR_COLD void Varray_get___024root__trace_init_sub__TOP__0(Varray_get___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBus(c+1,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+2,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+3,0,"res",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->pushPrefix("Foo", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+1,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+2,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+3,0,"res",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->popPrefix();
}

VL_ATTR_COLD void Varray_get___024root__trace_init_top(Varray_get___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root__trace_init_top\n"); );
    // Body
    Varray_get___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Varray_get___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Varray_get___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Varray_get___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Varray_get___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Varray_get___024root__trace_register(Varray_get___024root* vlSelf, VerilatedVcd* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root__trace_register\n"); );
    // Body
    tracep->addConstCb(&Varray_get___024root__trace_const_0, 0U, vlSelf);
    tracep->addFullCb(&Varray_get___024root__trace_full_0, 0U, vlSelf);
    tracep->addChgCb(&Varray_get___024root__trace_chg_0, 0U, vlSelf);
    tracep->addCleanupCb(&Varray_get___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Varray_get___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root__trace_const_0\n"); );
    // Init
    Varray_get___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Varray_get___024root*>(voidSelf);
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
}

VL_ATTR_COLD void Varray_get___024root__trace_full_0_sub_0(Varray_get___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Varray_get___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root__trace_full_0\n"); );
    // Init
    Varray_get___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Varray_get___024root*>(voidSelf);
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Varray_get___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Varray_get___024root__trace_full_0_sub_0(Varray_get___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Varray_get__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Varray_get___024root__trace_full_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullCData(oldp+1,(vlSelf->a),8);
    bufp->fullCData(oldp+2,(vlSelf->b),8);
    bufp->fullCData(oldp+3,(vlSelf->res),8);
}
