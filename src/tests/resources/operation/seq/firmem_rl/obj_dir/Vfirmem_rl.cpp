// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem_rl.h for the primary calling header

#include "Vfirmem_rl.h"
#include "Vfirmem_rl__Syms.h"

//==========

void Vfirmem_rl::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vfirmem_rl::eval\n"); );
    Vfirmem_rl__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Vfirmem_rl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        vlSymsp->__Vm_activity = true;
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("seq/firmem_rl/firmem_rl.sv", 92, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vfirmem_rl::_eval_initial_loop(Vfirmem_rl__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("seq/firmem_rl/firmem_rl.sv", 92, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void Vfirmem_rl::_sequent__TOP__1(Vfirmem_rl__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rl::_sequent__TOP__1\n"); );
    Vfirmem_rl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    CData/*1:0*/ __Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v0;
    CData/*7:0*/ __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v0;
    CData/*0:0*/ __Vdlyvset__Foo__DOT__memory_ext__DOT__Memory__v0;
    // Body
    __Vdlyvset__Foo__DOT__memory_ext__DOT__Memory__v0 = 0U;
    vlTOPp->Foo__DOT__memory_ext__DOT___R0_addr_d0 
        = vlTOPp->addr_r;
    vlTOPp->Foo__DOT__memory_ext__DOT___R0_en_d0 = vlTOPp->enable_r;
    if (vlTOPp->enable_w) {
        __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v0 
            = vlTOPp->data_in_w;
        __Vdlyvset__Foo__DOT__memory_ext__DOT__Memory__v0 = 1U;
        __Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v0 
            = vlTOPp->addr_w;
    }
    if (__Vdlyvset__Foo__DOT__memory_ext__DOT__Memory__v0) {
        vlTOPp->Foo__DOT__memory_ext__DOT__Memory[__Vdlyvdim0__Foo__DOT__memory_ext__DOT__Memory__v0] 
            = __Vdlyvval__Foo__DOT__memory_ext__DOT__Memory__v0;
    }
    vlTOPp->read_out = ((IData)(vlTOPp->Foo__DOT__memory_ext__DOT___R0_en_d0)
                         ? vlTOPp->Foo__DOT__memory_ext__DOT__Memory
                        [vlTOPp->Foo__DOT__memory_ext__DOT___R0_addr_d0]
                         : 0U);
}

void Vfirmem_rl::_eval(Vfirmem_rl__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rl::_eval\n"); );
    Vfirmem_rl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((IData)(vlTOPp->clk) & (~ (IData)(vlTOPp->__Vclklast__TOP__clk)))) {
        vlTOPp->_sequent__TOP__1(vlSymsp);
        vlTOPp->__Vm_traceActivity[1U] = 1U;
    }
    // Final
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

VL_INLINE_OPT QData Vfirmem_rl::_change_request(Vfirmem_rl__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rl::_change_request\n"); );
    Vfirmem_rl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    return (vlTOPp->_change_request_1(vlSymsp));
}

VL_INLINE_OPT QData Vfirmem_rl::_change_request_1(Vfirmem_rl__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rl::_change_request_1\n"); );
    Vfirmem_rl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Vfirmem_rl::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rl::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((addr_r & 0xfcU))) {
        Verilated::overWidthError("addr_r");}
    if (VL_UNLIKELY((addr_w & 0xfcU))) {
        Verilated::overWidthError("addr_w");}
    if (VL_UNLIKELY((addr_rw & 0xfcU))) {
        Verilated::overWidthError("addr_rw");}
    if (VL_UNLIKELY((mode & 0xfeU))) {
        Verilated::overWidthError("mode");}
    if (VL_UNLIKELY((enable_r & 0xfeU))) {
        Verilated::overWidthError("enable_r");}
    if (VL_UNLIKELY((enable_w & 0xfeU))) {
        Verilated::overWidthError("enable_w");}
    if (VL_UNLIKELY((enable_rw & 0xfeU))) {
        Verilated::overWidthError("enable_rw");}
}
#endif  // VL_DEBUG
