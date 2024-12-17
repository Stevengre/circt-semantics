// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vdivs.h for the primary calling header

#include "Vdivs__pch.h"
#include "Vdivs__Syms.h"
#include "Vdivs___024root.h"

void Vdivs___024root___ctor_var_reset(Vdivs___024root* vlSelf);

Vdivs___024root::Vdivs___024root(Vdivs__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vdivs___024root___ctor_var_reset(this);
}

void Vdivs___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vdivs___024root::~Vdivs___024root() {
}
