// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vverbatim.h for the primary calling header

#include "Vverbatim__pch.h"
#include "Vverbatim__Syms.h"
#include "Vverbatim___024root.h"

void Vverbatim___024root___ctor_var_reset(Vverbatim___024root* vlSelf);

Vverbatim___024root::Vverbatim___024root(Vverbatim__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vverbatim___024root___ctor_var_reset(this);
}

void Vverbatim___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vverbatim___024root::~Vverbatim___024root() {
}
