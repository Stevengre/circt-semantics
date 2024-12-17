// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Verror.h for the primary calling header

#include "Verror__pch.h"
#include "Verror__Syms.h"
#include "Verror___024root.h"

void Verror___024root___ctor_var_reset(Verror___024root* vlSelf);

Verror___024root::Verror___024root(Verror__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Verror___024root___ctor_var_reset(this);
}

void Verror___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Verror___024root::~Verror___024root() {
}
