// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VMODS__SYMS_H_
#define VERILATED_VMODS__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vmods.h"

// INCLUDE MODULE CLASSES
#include "Vmods___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vmods__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vmods* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vmods___024root                TOP;

    // CONSTRUCTORS
    Vmods__Syms(VerilatedContext* contextp, const char* namep, Vmods* modelp);
    ~Vmods__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
