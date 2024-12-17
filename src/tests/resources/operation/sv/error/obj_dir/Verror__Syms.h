// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VERROR__SYMS_H_
#define VERILATED_VERROR__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Verror.h"

// INCLUDE MODULE CLASSES
#include "Verror___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Verror__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Verror* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Verror___024root               TOP;

    // SCOPE NAMES
    VerilatedScope __Vscope_Foo;

    // CONSTRUCTORS
    Verror__Syms(VerilatedContext* contextp, const char* namep, Verror* modelp);
    ~Verror__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
