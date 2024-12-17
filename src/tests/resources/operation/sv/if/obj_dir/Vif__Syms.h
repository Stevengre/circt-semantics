// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VIF__SYMS_H_
#define VERILATED_VIF__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vif.h"

// INCLUDE MODULE CLASSES
#include "Vif___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vif__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vif* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vif___024root                  TOP;

    // SCOPE NAMES
    VerilatedScope __Vscope_Foo;

    // CONSTRUCTORS
    Vif__Syms(VerilatedContext* contextp, const char* namep, Vif* modelp);
    ~Vif__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
