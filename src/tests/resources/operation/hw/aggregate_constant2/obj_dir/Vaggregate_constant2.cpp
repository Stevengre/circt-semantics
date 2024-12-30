// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vaggregate_constant2.h for the primary calling header

#include "Vaggregate_constant2.h"
#include "Vaggregate_constant2__Syms.h"

//==========

void Vaggregate_constant2::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vaggregate_constant2::eval\n"); );
    Vaggregate_constant2__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
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
            VL_FATAL_MT("hw/aggregate_constant2/aggregate_constant2.sv", 2, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vaggregate_constant2::_eval_initial_loop(Vaggregate_constant2__Syms* __restrict vlSymsp) {
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
            VL_FATAL_MT("hw/aggregate_constant2/aggregate_constant2.sv", 2, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void Vaggregate_constant2::_combo__TOP__1(Vaggregate_constant2__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant2::_combo__TOP__1\n"); );
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->res = (0xffU & ((0xff000102U >> (0x1fU 
                                             & ((IData)(vlTOPp->a) 
                                                << 3U))) 
                            + (IData)(vlTOPp->b)));
}

void Vaggregate_constant2::_eval(Vaggregate_constant2__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant2::_eval\n"); );
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__1(vlSymsp);
}

VL_INLINE_OPT QData Vaggregate_constant2::_change_request(Vaggregate_constant2__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant2::_change_request\n"); );
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    return (vlTOPp->_change_request_1(vlSymsp));
}

VL_INLINE_OPT QData Vaggregate_constant2::_change_request_1(Vaggregate_constant2__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant2::_change_request_1\n"); );
    Vaggregate_constant2* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Vaggregate_constant2::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaggregate_constant2::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((a & 0xfcU))) {
        Verilated::overWidthError("a");}
}
#endif  // VL_DEBUG
