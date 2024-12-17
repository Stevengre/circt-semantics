// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vfatal__pch.h"
#include "Vfatal.h"
#include "Vfatal___024root.h"

// FUNCTIONS
Vfatal__Syms::~Vfatal__Syms()
{
}

Vfatal__Syms::Vfatal__Syms(VerilatedContext* contextp, const char* namep, Vfatal* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
{
        // Check resources
        Verilated::stackCheck(25);
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-12);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    // Setup scopes
    __Vscope_Foo.configure(this, name(), "Foo", "Foo", -12, VerilatedScope::SCOPE_OTHER);
}
