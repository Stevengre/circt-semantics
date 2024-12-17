// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vfor__pch.h"
#include "Vfor.h"
#include "Vfor___024root.h"

// FUNCTIONS
Vfor__Syms::~Vfor__Syms()
{
}

Vfor__Syms::Vfor__Syms(VerilatedContext* contextp, const char* namep, Vfor* modelp)
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
    __Vscope_Foo__unnamedblk1.configure(this, name(), "Foo.unnamedblk1", "unnamedblk1", -12, VerilatedScope::SCOPE_OTHER);
}
