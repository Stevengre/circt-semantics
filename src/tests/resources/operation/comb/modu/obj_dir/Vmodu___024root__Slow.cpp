// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmodu.h for the primary calling header

#include "Vmodu__pch.h"
#include "Vmodu__Syms.h"
#include "Vmodu___024root.h"

void Vmodu___024root___ctor_var_reset(Vmodu___024root* vlSelf);

Vmodu___024root::Vmodu___024root(Vmodu__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vmodu___024root___ctor_var_reset(this);
}

void Vmodu___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vmodu___024root::~Vmodu___024root() {
}
