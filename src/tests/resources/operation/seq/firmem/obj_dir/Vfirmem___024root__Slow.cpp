// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem.h for the primary calling header

#include "Vfirmem__pch.h"
#include "Vfirmem__Syms.h"
#include "Vfirmem___024root.h"

void Vfirmem___024root___ctor_var_reset(Vfirmem___024root* vlSelf);

Vfirmem___024root::Vfirmem___024root(Vfirmem__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vfirmem___024root___ctor_var_reset(this);
}

void Vfirmem___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vfirmem___024root::~Vfirmem___024root() {
}
