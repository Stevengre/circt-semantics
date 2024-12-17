// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vif.h for the primary calling header

#include "Vif__pch.h"
#include "Vif__Syms.h"
#include "Vif___024root.h"

void Vif___024root___ctor_var_reset(Vif___024root* vlSelf);

Vif___024root::Vif___024root(Vif__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vif___024root___ctor_var_reset(this);
}

void Vif___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vif___024root::~Vif___024root() {
}
