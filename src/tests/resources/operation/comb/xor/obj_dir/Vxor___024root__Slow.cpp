// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vxor.h for the primary calling header

#include "Vxor__pch.h"
#include "Vxor__Syms.h"
#include "Vxor___024root.h"

void Vxor___024root___ctor_var_reset(Vxor___024root* vlSelf);

Vxor___024root::Vxor___024root(Vxor__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vxor___024root___ctor_var_reset(this);
}

void Vxor___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vxor___024root::~Vxor___024root() {
}
