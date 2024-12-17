// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vshru.h for the primary calling header

#include "Vshru__pch.h"
#include "Vshru__Syms.h"
#include "Vshru___024root.h"

void Vshru___024root___ctor_var_reset(Vshru___024root* vlSelf);

Vshru___024root::Vshru___024root(Vshru__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vshru___024root___ctor_var_reset(this);
}

void Vshru___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vshru___024root::~Vshru___024root() {
}
