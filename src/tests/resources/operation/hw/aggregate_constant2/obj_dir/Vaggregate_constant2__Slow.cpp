// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vaggregate_constant2.h for the primary calling header

#include "Vaggregate_constant2.h"
#include "Vaggregate_constant2__Syms.h"

//==========

VL_CTOR_IMP(Vaggregate_constant2) {
    Vaggregate_constant2__Syms* __restrict vlSymsp = __VlSymsp = new Vaggregate_constant2__Syms(this, name());
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vaggregate_constant2::__Vconfigure(Vaggregate_constant2__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-12);
    Verilated::timeprecision(-12);
}

Vaggregate_constant2::~Vaggregate_constant2() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = NULL);
}

void Vaggregate_constant2::_eval_initial(Vaggregate_constant2__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant2::_eval_initial\n"); );
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vaggregate_constant2::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant2::final\n"); );
    // Variables
    Vaggregate_constant2__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vaggregate_constant2::_eval_settle(Vaggregate_constant2__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant2::_eval_settle\n"); );
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__1(vlSymsp);
}

void Vaggregate_constant2::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant2::_ctor_var_reset\n"); );
    // Body
    a = VL_RAND_RESET_I(2);
    b = VL_RAND_RESET_I(8);
    res = VL_RAND_RESET_I(8);
    { int __Vi0=0; for (; __Vi0<1; ++__Vi0) {
            __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }}
}
