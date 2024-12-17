// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vdivu.h for the primary calling header

#include "Vdivu__pch.h"
#include "Vdivu__Syms.h"
#include "Vdivu___024root.h"

void Vdivu___024root___ctor_var_reset(Vdivu___024root* vlSelf);

Vdivu___024root::Vdivu___024root(Vdivu__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vdivu___024root___ctor_var_reset(this);
}

void Vdivu___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vdivu___024root::~Vdivu___024root() {
}
