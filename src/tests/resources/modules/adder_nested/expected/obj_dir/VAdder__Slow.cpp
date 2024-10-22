// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VAdder.h for the primary calling header

#include "VAdder.h"
#include "VAdder__Syms.h"

//==========

VL_CTOR_IMP(VAdder) {
    VAdder__Syms* __restrict vlSymsp = __VlSymsp = new VAdder__Syms(this, name());
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void VAdder::__Vconfigure(VAdder__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-12);
    Verilated::timeprecision(-12);
}

VAdder::~VAdder() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = NULL);
}

void VAdder::_eval_initial(VAdder__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VAdder::_eval_initial\n"); );
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void VAdder::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VAdder::final\n"); );
    // Variables
    VAdder__Syms* __restrict vlSymsp = this->__VlSymsp;
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void VAdder::_eval_settle(VAdder__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VAdder::_eval_settle\n"); );
    VAdder* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__1(vlSymsp);
}

void VAdder::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VAdder::_ctor_var_reset\n"); );
    // Body
    io_a = VL_RAND_RESET_I(8);
    res_out2 = VL_RAND_RESET_I(8);
    res_out1 = VL_RAND_RESET_I(8);
    { int __Vi0=0; for (; __Vi0<1; ++__Vi0) {
            __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }}
}
