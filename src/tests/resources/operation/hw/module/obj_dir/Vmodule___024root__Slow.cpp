// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmodule.h for the primary calling header

#include "Vmodule__pch.h"
#include "Vmodule__Syms.h"
#include "Vmodule___024root.h"

void Vmodule___024root___ctor_var_reset(Vmodule___024root* vlSelf);

Vmodule___024root::Vmodule___024root(Vmodule__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vmodule___024root___ctor_var_reset(this);
}

void Vmodule___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vmodule___024root::~Vmodule___024root() {
}
