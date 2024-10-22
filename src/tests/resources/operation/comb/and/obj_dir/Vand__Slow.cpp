// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vand.h for the primary calling header

#include "Vand.h"
#include "Vand__Syms.h"

//==========

VL_CTOR_IMP(Vand) {
    Vand__Syms* __restrict vlSymsp = __VlSymsp = new Vand__Syms(this, name());
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vand::__Vconfigure(Vand__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-12);
    Verilated::timeprecision(-12);
}

Vand::~Vand() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = NULL);
}

void Vand::_eval_initial(Vand__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vand::_eval_initial\n"); );
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vand::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vand::final\n"); );
    // Variables
    Vand__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vand::_eval_settle(Vand__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vand::_eval_settle\n"); );
    Vand* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__1(vlSymsp);
}

void Vand::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vand::_ctor_var_reset\n"); );
    // Body
    a = VL_RAND_RESET_I(8);
    b = VL_RAND_RESET_I(8);
    res = VL_RAND_RESET_I(8);
    { int __Vi0=0; for (; __Vi0<1; ++__Vi0) {
            __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }}
}
