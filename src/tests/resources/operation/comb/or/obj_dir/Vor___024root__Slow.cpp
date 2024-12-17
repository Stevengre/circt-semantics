// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vor.h for the primary calling header

#include "Vor__pch.h"
#include "Vor__Syms.h"
#include "Vor___024root.h"

void Vor___024root___ctor_var_reset(Vor___024root* vlSelf);

Vor___024root::Vor___024root(Vor__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vor___024root___ctor_var_reset(this);
}

void Vor___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vor___024root::~Vor___024root() {
}
