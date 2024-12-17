// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmods.h for the primary calling header

#include "Vmods__pch.h"
#include "Vmods__Syms.h"
#include "Vmods___024root.h"

void Vmods___024root___ctor_var_reset(Vmods___024root* vlSelf);

Vmods___024root::Vmods___024root(Vmods__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vmods___024root___ctor_var_reset(this);
}

void Vmods___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vmods___024root::~Vmods___024root() {
}
