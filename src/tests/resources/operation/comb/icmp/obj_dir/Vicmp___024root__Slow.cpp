// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vicmp.h for the primary calling header

#include "Vicmp__pch.h"
#include "Vicmp__Syms.h"
#include "Vicmp___024root.h"

void Vicmp___024root___ctor_var_reset(Vicmp___024root* vlSelf);

Vicmp___024root::Vicmp___024root(Vicmp__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vicmp___024root___ctor_var_reset(this);
}

void Vicmp___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vicmp___024root::~Vicmp___024root() {
}
