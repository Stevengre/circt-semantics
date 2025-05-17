// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem_rwl.h for the primary calling header

#include "Vfirmem_rwl.h"
#include "Vfirmem_rwl__Syms.h"

//==========

VL_CTOR_IMP(Vfirmem_rwl) {
    Vfirmem_rwl__Syms* __restrict vlSymsp = __VlSymsp = new Vfirmem_rwl__Syms(this, name());
    Vfirmem_rwl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vfirmem_rwl::__Vconfigure(Vfirmem_rwl__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-12);
    Verilated::timeprecision(-12);
}

Vfirmem_rwl::~Vfirmem_rwl() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = NULL);
}

void Vfirmem_rwl::_settle__TOP__2(Vfirmem_rwl__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rwl::_settle__TOP__2\n"); );
    Vfirmem_rwl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->read_out = ((IData)(vlTOPp->Foo__DOT__memory_ext__DOT___R0_en_d0)
                         ? vlTOPp->Foo__DOT__memory_ext__DOT__Memory
                        [vlTOPp->Foo__DOT__memory_ext__DOT___R0_addr_d0]
                         : 0U);
    vlTOPp->rw_out = (((IData)(vlTOPp->Foo__DOT__memory_ext__DOT___RW0_ren_d0) 
                       & (~ (IData)(vlTOPp->Foo__DOT__memory_ext__DOT___RW0_rmode_d0)))
                       ? vlTOPp->Foo__DOT__memory_ext__DOT__Memory
                      [vlTOPp->Foo__DOT__memory_ext__DOT___RW0_raddr_d0]
                       : 0U);
}

void Vfirmem_rwl::_eval_initial(Vfirmem_rwl__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rwl::_eval_initial\n"); );
    Vfirmem_rwl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

void Vfirmem_rwl::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rwl::final\n"); );
    // Variables
    Vfirmem_rwl__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vfirmem_rwl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vfirmem_rwl::_eval_settle(Vfirmem_rwl__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rwl::_eval_settle\n"); );
    Vfirmem_rwl* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__2(vlSymsp);
}

void Vfirmem_rwl::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rwl::_ctor_var_reset\n"); );
    // Body
    clk = VL_RAND_RESET_I(1);
    data_in_w = VL_RAND_RESET_I(8);
    data_in_rw = VL_RAND_RESET_I(8);
    addr_r = VL_RAND_RESET_I(2);
    addr_w = VL_RAND_RESET_I(2);
    addr_rw = VL_RAND_RESET_I(2);
    mode = VL_RAND_RESET_I(1);
    enable_r = VL_RAND_RESET_I(1);
    enable_w = VL_RAND_RESET_I(1);
    enable_rw = VL_RAND_RESET_I(1);
    read_out = VL_RAND_RESET_I(8);
    rw_out = VL_RAND_RESET_I(8);
    { int __Vi0=0; for (; __Vi0<4; ++__Vi0) {
            Foo__DOT__memory_ext__DOT__Memory[__Vi0] = VL_RAND_RESET_I(8);
    }}
    Foo__DOT__memory_ext__DOT___R0_en_d0 = VL_RAND_RESET_I(1);
    Foo__DOT__memory_ext__DOT___R0_addr_d0 = VL_RAND_RESET_I(2);
    Foo__DOT__memory_ext__DOT___RW0_raddr_d0 = VL_RAND_RESET_I(2);
    Foo__DOT__memory_ext__DOT___RW0_ren_d0 = VL_RAND_RESET_I(1);
    Foo__DOT__memory_ext__DOT___RW0_rmode_d0 = VL_RAND_RESET_I(1);
    { int __Vi0=0; for (; __Vi0<2; ++__Vi0) {
            __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }}
}
