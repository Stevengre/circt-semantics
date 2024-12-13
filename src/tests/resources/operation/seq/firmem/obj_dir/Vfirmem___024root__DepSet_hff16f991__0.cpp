// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem.h for the primary calling header

#include "Vfirmem__pch.h"
#include "Vfirmem___024root.h"

VL_INLINE_OPT void Vfirmem___024root___ico_sequent__TOP__0(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___ico_sequent__TOP__0\n"); );
    // Body
    vlSelf->read_out = vlSelf->Foo__DOT__memory_ext__DOT__Memory
        [vlSelf->addr];
    vlSelf->rw_out = ((IData)(vlSelf->mode) ? 0U : (IData)(vlSelf->read_out));
}

void Vfirmem___024root___eval_ico(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_ico\n"); );
    // Body
    if ((1ULL & vlSelf->__VicoTriggered.word(0U))) {
        Vfirmem___024root___ico_sequent__TOP__0(vlSelf);
    }
}

void Vfirmem___024root___eval_triggers__ico(Vfirmem___024root* vlSelf);

bool Vfirmem___024root___eval_phase__ico(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_phase__ico\n"); );
    // Init
    CData/*0:0*/ __VicoExecute;
    // Body
    Vfirmem___024root___eval_triggers__ico(vlSelf);
    __VicoExecute = vlSelf->__VicoTriggered.any();
    if (__VicoExecute) {
        Vfirmem___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

void Vfirmem___024root___eval_act(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_act\n"); );
}

VL_INLINE_OPT void Vfirmem___024root___nba_sequent__TOP__0(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___nba_sequent__TOP__0\n"); );
    // Init
    CData/*1:0*/ __Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v0;
    __Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v0 = 0;
    CData/*7:0*/ __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v0;
    __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v0 = 0;
    CData/*0:0*/ __Vdlyvset__Foo__DOT__memory_ext__DOT__Memory__v0;
    __Vdlyvset__Foo__DOT__memory_ext__DOT__Memory__v0 = 0;
    CData/*1:0*/ __Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v1;
    __Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v1 = 0;
    CData/*7:0*/ __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v1;
    __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v1 = 0;
    // Body
    __Vdlyvset__Foo__DOT__memory_ext__DOT__Memory__v0 = 0U;
    __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v1 
        = vlSelf->data_in;
    __Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v1 
        = vlSelf->addr;
    if (vlSelf->mode) {
        __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v0 
            = vlSelf->data_in;
        __Vdlyvset__Foo__DOT__memory_ext__DOT__Memory__v0 = 1U;
        __Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v0 
            = vlSelf->addr;
    }
    if (__Vdlyvset__Foo__DOT__memory_ext__DOT__Memory__v0) {
        vlSelf->Foo__DOT__memory_ext__DOT__Memory[__Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v0] 
            = __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v0;
    }
    vlSelf->Foo__DOT__memory_ext__DOT__Memory[__Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v1] 
        = __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v1;
    vlSelf->read_out = vlSelf->Foo__DOT__memory_ext__DOT__Memory
        [vlSelf->addr];
    vlSelf->rw_out = ((IData)(vlSelf->mode) ? 0U : (IData)(vlSelf->read_out));
}

void Vfirmem___024root___eval_nba(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_nba\n"); );
    // Body
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        Vfirmem___024root___nba_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[1U] = 1U;
    }
}

void Vfirmem___024root___eval_triggers__act(Vfirmem___024root* vlSelf);

bool Vfirmem___024root___eval_phase__act(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_phase__act\n"); );
    // Init
    VlTriggerVec<1> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vfirmem___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelf->__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
        vlSelf->__VnbaTriggered.thisOr(vlSelf->__VactTriggered);
        Vfirmem___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vfirmem___024root___eval_phase__nba(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_phase__nba\n"); );
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelf->__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vfirmem___024root___eval_nba(vlSelf);
        vlSelf->__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem___024root___dump_triggers__ico(Vfirmem___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem___024root___dump_triggers__nba(Vfirmem___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem___024root___dump_triggers__act(Vfirmem___024root* vlSelf);
#endif  // VL_DEBUG

void Vfirmem___024root___eval(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval\n"); );
    // Init
    IData/*31:0*/ __VicoIterCount;
    CData/*0:0*/ __VicoContinue;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VicoIterCount = 0U;
    vlSelf->__VicoFirstIteration = 1U;
    __VicoContinue = 1U;
    while (__VicoContinue) {
        if (VL_UNLIKELY((0x64U < __VicoIterCount))) {
#ifdef VL_DEBUG
            Vfirmem___024root___dump_triggers__ico(vlSelf);
#endif
            VL_FATAL_MT("seq/firmem/firmem.sv", 89, "", "Input combinational region did not converge.");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
        __VicoContinue = 0U;
        if (Vfirmem___024root___eval_phase__ico(vlSelf)) {
            __VicoContinue = 1U;
        }
        vlSelf->__VicoFirstIteration = 0U;
    }
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Vfirmem___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("seq/firmem/firmem.sv", 89, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelf->__VactIterCount = 0U;
        vlSelf->__VactContinue = 1U;
        while (vlSelf->__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                Vfirmem___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("seq/firmem/firmem.sv", 89, "", "Active region did not converge.");
            }
            vlSelf->__VactIterCount = ((IData)(1U) 
                                       + vlSelf->__VactIterCount);
            vlSelf->__VactContinue = 0U;
            if (Vfirmem___024root___eval_phase__act(vlSelf)) {
                vlSelf->__VactContinue = 1U;
            }
        }
        if (Vfirmem___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vfirmem___024root___eval_debug_assertions(Vfirmem___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((vlSelf->reset & 0xfeU))) {
        Verilated::overWidthError("reset");}
    if (VL_UNLIKELY((vlSelf->addr & 0xfcU))) {
        Verilated::overWidthError("addr");}
    if (VL_UNLIKELY((vlSelf->mode & 0xfeU))) {
        Verilated::overWidthError("mode");}
}
#endif  // VL_DEBUG
