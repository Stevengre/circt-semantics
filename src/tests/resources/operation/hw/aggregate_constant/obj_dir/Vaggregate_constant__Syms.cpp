// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vaggregate_constant__pch.h"
#include "Vaggregate_constant.h"
#include "Vaggregate_constant___024root.h"

// FUNCTIONS
Vaggregate_constant__Syms::~Vaggregate_constant__Syms()
{
}

Vaggregate_constant__Syms::Vaggregate_constant__Syms(VerilatedContext* contextp, const char* namep, Vaggregate_constant* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
{
        // Check resources
        Verilated::stackCheck(11);
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-12);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
}
