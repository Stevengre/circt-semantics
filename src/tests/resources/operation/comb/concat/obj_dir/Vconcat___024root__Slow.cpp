// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vconcat.h for the primary calling header

#include "Vconcat__pch.h"
#include "Vconcat__Syms.h"
#include "Vconcat___024root.h"

void Vconcat___024root___ctor_var_reset(Vconcat___024root* vlSelf);

Vconcat___024root::Vconcat___024root(Vconcat__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vconcat___024root___ctor_var_reset(this);
}

void Vconcat___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vconcat___024root::~Vconcat___024root() {
}
