// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VOR__SYMS_H_
#define VERILATED_VOR__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vor.h"

// INCLUDE MODULE CLASSES
#include "Vor___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vor__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vor* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vor___024root                  TOP;

    // CONSTRUCTORS
    Vor__Syms(VerilatedContext* contextp, const char* namep, Vor* modelp);
    ~Vor__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
