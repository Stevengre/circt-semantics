// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vparity.h for the primary calling header

#include "Vparity__pch.h"
#include "Vparity__Syms.h"
#include "Vparity___024root.h"

void Vparity___024root___ctor_var_reset(Vparity___024root* vlSelf);

Vparity___024root::Vparity___024root(Vparity__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vparity___024root___ctor_var_reset(this);
}

void Vparity___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vparity___024root::~Vparity___024root() {
}
