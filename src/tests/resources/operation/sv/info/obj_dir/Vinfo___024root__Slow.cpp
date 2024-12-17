// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vinfo.h for the primary calling header

#include "Vinfo__pch.h"
#include "Vinfo__Syms.h"
#include "Vinfo___024root.h"

void Vinfo___024root___ctor_var_reset(Vinfo___024root* vlSelf);

Vinfo___024root::Vinfo___024root(Vinfo__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vinfo___024root___ctor_var_reset(this);
}

void Vinfo___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vinfo___024root::~Vinfo___024root() {
}
