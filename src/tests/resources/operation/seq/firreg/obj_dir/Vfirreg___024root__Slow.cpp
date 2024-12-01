// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirreg.h for the primary calling header

#include "Vfirreg__pch.h"
#include "Vfirreg__Syms.h"
#include "Vfirreg___024root.h"

void Vfirreg___024root___ctor_var_reset(Vfirreg___024root* vlSelf);

Vfirreg___024root::Vfirreg___024root(Vfirreg__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vfirreg___024root___ctor_var_reset(this);
}

void Vfirreg___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vfirreg___024root::~Vfirreg___024root() {
}
