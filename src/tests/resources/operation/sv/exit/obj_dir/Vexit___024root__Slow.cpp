// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vexit.h for the primary calling header

#include "Vexit__pch.h"
#include "Vexit__Syms.h"
#include "Vexit___024root.h"

void Vexit___024root___ctor_var_reset(Vexit___024root* vlSelf);

Vexit___024root::Vexit___024root(Vexit__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vexit___024root___ctor_var_reset(this);
}

void Vexit___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vexit___024root::~Vexit___024root() {
}
