// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem_mask.h for the primary calling header

#include "Vfirmem_mask__pch.h"
#include "Vfirmem_mask___024root.h"

void Vfirmem_mask___024root___eval_act(Vfirmem_mask___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root___eval_act\n"); );
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vfirmem_mask___024root___nba_sequent__TOP__0(Vfirmem_mask___024root* vlSelf);

void Vfirmem_mask___024root___eval_nba(Vfirmem_mask___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root___eval_nba\n"); );
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vfirmem_mask___024root___nba_sequent__TOP__0(vlSelf);
        vlSelfRef.__Vm_traceActivity[1U] = 1U;
    }
}

VL_INLINE_OPT void Vfirmem_mask___024root___nba_sequent__TOP__0(Vfirmem_mask___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root___nba_sequent__TOP__0\n"); );
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*3:0*/ __VdlyVal__Foo__DOT__memory_ext__DOT__Memory__v0;
    __VdlyVal__Foo__DOT__memory_ext__DOT__Memory__v0 = 0;
    CData/*1:0*/ __VdlyDim0__Foo__DOT__memory_ext__DOT__Memory__v0;
    __VdlyDim0__Foo__DOT__memory_ext__DOT__Memory__v0 = 0;
    CData/*0:0*/ __VdlySet__Foo__DOT__memory_ext__DOT__Memory__v0;
    __VdlySet__Foo__DOT__memory_ext__DOT__Memory__v0 = 0;
    CData/*3:0*/ __VdlyVal__Foo__DOT__memory_ext__DOT__Memory__v1;
    __VdlyVal__Foo__DOT__memory_ext__DOT__Memory__v1 = 0;
    CData/*1:0*/ __VdlyDim0__Foo__DOT__memory_ext__DOT__Memory__v1;
    __VdlyDim0__Foo__DOT__memory_ext__DOT__Memory__v1 = 0;
    CData/*0:0*/ __VdlySet__Foo__DOT__memory_ext__DOT__Memory__v1;
    __VdlySet__Foo__DOT__memory_ext__DOT__Memory__v1 = 0;
    // Body
    __VdlySet__Foo__DOT__memory_ext__DOT__Memory__v0 = 0U;
    __VdlySet__Foo__DOT__memory_ext__DOT__Memory__v1 = 0U;
    if ((((IData)(vlSelfRef.enable_rw) & (IData)(vlSelfRef.mask_in)) 
         & (IData)(vlSelfRef.mode))) {
        __VdlyVal__Foo__DOT__memory_ext__DOT__Memory__v0 
            = (0xfU & (IData)(vlSelfRef.data_in_rw));
        __VdlyDim0__Foo__DOT__memory_ext__DOT__Memory__v0 
            = vlSelfRef.addr_rw;
        __VdlySet__Foo__DOT__memory_ext__DOT__Memory__v0 = 1U;
    }
    if ((((IData)(vlSelfRef.enable_rw) & ((IData)(vlSelfRef.mask_in) 
                                          >> 1U)) & (IData)(vlSelfRef.mode))) {
        __VdlyVal__Foo__DOT__memory_ext__DOT__Memory__v1 
            = (0xfU & ((IData)(vlSelfRef.data_in_rw) 
                       >> 4U));
        __VdlyDim0__Foo__DOT__memory_ext__DOT__Memory__v1 
            = vlSelfRef.addr_rw;
        __VdlySet__Foo__DOT__memory_ext__DOT__Memory__v1 = 1U;
    }
    vlSelfRef.Foo__DOT__memory_ext__DOT___RW0_raddr_d0 
        = vlSelfRef.addr_rw;
    vlSelfRef.Foo__DOT__memory_ext__DOT___RW0_ren_d0 
        = vlSelfRef.enable_rw;
    vlSelfRef.Foo__DOT__memory_ext__DOT___RW0_rmode_d0 
        = vlSelfRef.mode;
    if (__VdlySet__Foo__DOT__memory_ext__DOT__Memory__v0) {
        vlSelfRef.Foo__DOT__memory_ext__DOT__Memory[__VdlyDim0__Foo__DOT__memory_ext__DOT__Memory__v0] 
            = ((0xf0U & vlSelfRef.Foo__DOT__memory_ext__DOT__Memory
                [__VdlyDim0__Foo__DOT__memory_ext__DOT__Memory__v0]) 
               | (IData)(__VdlyVal__Foo__DOT__memory_ext__DOT__Memory__v0));
    }
    if (__VdlySet__Foo__DOT__memory_ext__DOT__Memory__v1) {
        vlSelfRef.Foo__DOT__memory_ext__DOT__Memory[__VdlyDim0__Foo__DOT__memory_ext__DOT__Memory__v1] 
            = ((0xfU & vlSelfRef.Foo__DOT__memory_ext__DOT__Memory
                [__VdlyDim0__Foo__DOT__memory_ext__DOT__Memory__v1]) 
               | ((IData)(__VdlyVal__Foo__DOT__memory_ext__DOT__Memory__v1) 
                  << 4U));
    }
    vlSelfRef.rw_out = (((~ (IData)(vlSelfRef.Foo__DOT__memory_ext__DOT___RW0_rmode_d0)) 
                         & (IData)(vlSelfRef.Foo__DOT__memory_ext__DOT___RW0_ren_d0))
                         ? vlSelfRef.Foo__DOT__memory_ext__DOT__Memory
                        [vlSelfRef.Foo__DOT__memory_ext__DOT___RW0_raddr_d0]
                         : 0U);
}

void Vfirmem_mask___024root___eval_triggers__act(Vfirmem_mask___024root* vlSelf);

bool Vfirmem_mask___024root___eval_phase__act(Vfirmem_mask___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root___eval_phase__act\n"); );
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<1> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vfirmem_mask___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vfirmem_mask___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vfirmem_mask___024root___eval_phase__nba(Vfirmem_mask___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root___eval_phase__nba\n"); );
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vfirmem_mask___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem_mask___024root___dump_triggers__nba(Vfirmem_mask___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vfirmem_mask___024root___dump_triggers__act(Vfirmem_mask___024root* vlSelf);
#endif  // VL_DEBUG

void Vfirmem_mask___024root___eval(Vfirmem_mask___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root___eval\n"); );
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY(((0x64U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vfirmem_mask___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("seq/firmem_mask/firmem_mask.sv", 94, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY(((0x64U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vfirmem_mask___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("seq/firmem_mask/firmem_mask.sv", 94, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vfirmem_mask___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vfirmem_mask___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vfirmem_mask___024root___eval_debug_assertions(Vfirmem_mask___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_mask___024root___eval_debug_assertions\n"); );
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.clk & 0xfeU)))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY(((vlSelfRef.addr_r & 0xfcU)))) {
        Verilated::overWidthError("addr_r");}
    if (VL_UNLIKELY(((vlSelfRef.addr_w & 0xfcU)))) {
        Verilated::overWidthError("addr_w");}
    if (VL_UNLIKELY(((vlSelfRef.addr_rw & 0xfcU)))) {
        Verilated::overWidthError("addr_rw");}
    if (VL_UNLIKELY(((vlSelfRef.mode & 0xfeU)))) {
        Verilated::overWidthError("mode");}
    if (VL_UNLIKELY(((vlSelfRef.enable_r & 0xfeU)))) {
        Verilated::overWidthError("enable_r");}
    if (VL_UNLIKELY(((vlSelfRef.enable_w & 0xfeU)))) {
        Verilated::overWidthError("enable_w");}
    if (VL_UNLIKELY(((vlSelfRef.enable_rw & 0xfeU)))) {
        Verilated::overWidthError("enable_rw");}
    if (VL_UNLIKELY(((vlSelfRef.mask_in & 0xfcU)))) {
        Verilated::overWidthError("mask_in");}
}
#endif  // VL_DEBUG
