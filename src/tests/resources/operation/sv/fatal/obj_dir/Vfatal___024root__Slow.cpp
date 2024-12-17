// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfatal.h for the primary calling header

#include "Vfatal__pch.h"
#include "Vfatal__Syms.h"
#include "Vfatal___024root.h"

void Vfatal___024root___ctor_var_reset(Vfatal___024root* vlSelf);

Vfatal___024root::Vfatal___024root(Vfatal__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vfatal___024root___ctor_var_reset(this);
}

void Vfatal___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vfatal___024root::~Vfatal___024root() {
}
