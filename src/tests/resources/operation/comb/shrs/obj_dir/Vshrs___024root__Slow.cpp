// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vshrs.h for the primary calling header

#include "Vshrs__pch.h"
#include "Vshrs__Syms.h"
#include "Vshrs___024root.h"

void Vshrs___024root___ctor_var_reset(Vshrs___024root* vlSelf);

Vshrs___024root::Vshrs___024root(Vshrs__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vshrs___024root___ctor_var_reset(this);
}

void Vshrs___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vshrs___024root::~Vshrs___024root() {
}
