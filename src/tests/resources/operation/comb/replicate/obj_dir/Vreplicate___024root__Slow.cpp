// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vreplicate.h for the primary calling header

#include "Vreplicate__pch.h"
#include "Vreplicate__Syms.h"
#include "Vreplicate___024root.h"

void Vreplicate___024root___ctor_var_reset(Vreplicate___024root* vlSelf);

Vreplicate___024root::Vreplicate___024root(Vreplicate__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vreplicate___024root___ctor_var_reset(this);
}

void Vreplicate___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vreplicate___024root::~Vreplicate___024root() {
}
