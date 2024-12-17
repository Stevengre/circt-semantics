// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vsub.h for the primary calling header

#include "Vsub__pch.h"
#include "Vsub__Syms.h"
#include "Vsub___024root.h"

void Vsub___024root___ctor_var_reset(Vsub___024root* vlSelf);

Vsub___024root::Vsub___024root(Vsub__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vsub___024root___ctor_var_reset(this);
}

void Vsub___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vsub___024root::~Vsub___024root() {
}
