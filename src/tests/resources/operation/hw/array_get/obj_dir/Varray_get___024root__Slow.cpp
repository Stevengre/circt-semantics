// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Varray_get.h for the primary calling header

#include "Varray_get__pch.h"
#include "Varray_get__Syms.h"
#include "Varray_get___024root.h"

void Varray_get___024root___ctor_var_reset(Varray_get___024root* vlSelf);

Varray_get___024root::Varray_get___024root(Varray_get__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Varray_get___024root___ctor_var_reset(this);
}

void Varray_get___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Varray_get___024root::~Varray_get___024root() {
}
