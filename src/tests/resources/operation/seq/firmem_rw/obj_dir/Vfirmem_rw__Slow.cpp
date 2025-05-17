// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem_rw.h for the primary calling header

#include "Vfirmem_rw.h"
#include "Vfirmem_rw__Syms.h"

//==========

VL_CTOR_IMP(Vfirmem_rw) {
    Vfirmem_rw__Syms* __restrict vlSymsp = __VlSymsp = new Vfirmem_rw__Syms(this, name());
    Vfirmem_rw* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vfirmem_rw::__Vconfigure(Vfirmem_rw__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-12);
    Verilated::timeprecision(-12);
}

Vfirmem_rw::~Vfirmem_rw() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = NULL);
}

void Vfirmem_rw::_eval_initial(Vfirmem_rw__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rw::_eval_initial\n"); );
    Vfirmem_rw* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

void Vfirmem_rw::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rw::final\n"); );
    // Variables
    Vfirmem_rw__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vfirmem_rw* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vfirmem_rw::_eval_settle(Vfirmem_rw__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rw::_eval_settle\n"); );
    Vfirmem_rw* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__2(vlSymsp);
}

void Vfirmem_rw::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vfirmem_rw::_ctor_var_reset\n"); );
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
    { int __Vi0=0; for (; __Vi0<2; ++__Vi0) {
            __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }}
}
