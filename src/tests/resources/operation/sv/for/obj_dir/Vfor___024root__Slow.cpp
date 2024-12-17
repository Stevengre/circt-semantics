// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfor.h for the primary calling header

#include "Vfor__pch.h"
#include "Vfor__Syms.h"
#include "Vfor___024root.h"

void Vfor___024root___ctor_var_reset(Vfor___024root* vlSelf);

Vfor___024root::Vfor___024root(Vfor__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vfor___024root___ctor_var_reset(this);
}

void Vfor___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vfor___024root::~Vfor___024root() {
}
