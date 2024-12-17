// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vassert.h for the primary calling header

#include "Vassert__pch.h"
#include "Vassert__Syms.h"
#include "Vassert___024root.h"

void Vassert___024root___ctor_var_reset(Vassert___024root* vlSelf);

Vassert___024root::Vassert___024root(Vassert__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vassert___024root___ctor_var_reset(this);
}

void Vassert___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vassert___024root::~Vassert___024root() {
}
