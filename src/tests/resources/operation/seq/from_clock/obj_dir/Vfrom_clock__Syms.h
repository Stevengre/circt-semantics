// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VFROM_CLOCK__SYMS_H_
#define VERILATED_VFROM_CLOCK__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vfrom_clock.h"

// INCLUDE MODULE CLASSES
#include "Vfrom_clock___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vfrom_clock__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vfrom_clock* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vfrom_clock___024root          TOP;

    // CONSTRUCTORS
    Vfrom_clock__Syms(VerilatedContext* contextp, const char* namep, Vfrom_clock* modelp);
    ~Vfrom_clock__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
