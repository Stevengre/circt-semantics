// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Valways.h for the primary calling header

#include "Valways__pch.h"
#include "Valways__Syms.h"
#include "Valways___024root.h"

void Valways___024root___ctor_var_reset(Valways___024root* vlSelf);

Valways___024root::Valways___024root(Valways__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Valways___024root___ctor_var_reset(this);
}

void Valways___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Valways___024root::~Valways___024root() {
}
