// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Varray_concat.h for the primary calling header

#include "Varray_concat__pch.h"
#include "Varray_concat__Syms.h"
#include "Varray_concat___024root.h"

void Varray_concat___024root___ctor_var_reset(Varray_concat___024root* vlSelf);

Varray_concat___024root::Varray_concat___024root(Varray_concat__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Varray_concat___024root___ctor_var_reset(this);
}

void Varray_concat___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Varray_concat___024root::~Varray_concat___024root() {
}
