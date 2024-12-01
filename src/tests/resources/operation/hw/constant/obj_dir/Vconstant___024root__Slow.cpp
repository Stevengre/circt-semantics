// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vconstant.h for the primary calling header

#include "Vconstant__pch.h"
#include "Vconstant__Syms.h"
#include "Vconstant___024root.h"

void Vconstant___024root___ctor_var_reset(Vconstant___024root* vlSelf);

Vconstant___024root::Vconstant___024root(Vconstant__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vconstant___024root___ctor_var_reset(this);
}

void Vconstant___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vconstant___024root::~Vconstant___024root() {
}
