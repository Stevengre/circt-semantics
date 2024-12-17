// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vextract.h for the primary calling header

#include "Vextract__pch.h"
#include "Vextract__Syms.h"
#include "Vextract___024root.h"

void Vextract___024root___ctor_var_reset(Vextract___024root* vlSelf);

Vextract___024root::Vextract___024root(Vextract__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vextract___024root___ctor_var_reset(this);
}

void Vextract___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vextract___024root::~Vextract___024root() {
}
