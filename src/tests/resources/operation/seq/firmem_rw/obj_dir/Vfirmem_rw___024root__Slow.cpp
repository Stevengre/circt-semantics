// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfirmem_rw.h for the primary calling header

#include "Vfirmem_rw__pch.h"
#include "Vfirmem_rw__Syms.h"
#include "Vfirmem_rw___024root.h"

void Vfirmem_rw___024root___ctor_var_reset(Vfirmem_rw___024root* vlSelf);

Vfirmem_rw___024root::Vfirmem_rw___024root(Vfirmem_rw__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vfirmem_rw___024root___ctor_var_reset(this);
}

void Vfirmem_rw___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vfirmem_rw___024root::~Vfirmem_rw___024root() {
}
