// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfinish.h for the primary calling header

#include "Vfinish__pch.h"
#include "Vfinish__Syms.h"
#include "Vfinish___024root.h"

void Vfinish___024root___ctor_var_reset(Vfinish___024root* vlSelf);

Vfinish___024root::Vfinish___024root(Vfinish__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vfinish___024root___ctor_var_reset(this);
}

void Vfinish___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vfinish___024root::~Vfinish___024root() {
}
