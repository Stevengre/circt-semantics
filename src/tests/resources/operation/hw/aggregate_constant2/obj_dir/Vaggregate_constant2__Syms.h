// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef _VAGGREGATE_CONSTANT2__SYMS_H_
#define _VAGGREGATE_CONSTANT2__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODULE CLASSES
#include "Vaggregate_constant2.h"

// SYMS CLASS
class Vaggregate_constant2__Syms : public VerilatedSyms {
  public:
    
    // LOCAL STATE
    const char* __Vm_namep;
    bool __Vm_activity;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode;  ///< Used by trace routines when tracing multiple models
    bool __Vm_didInit;
    
    // SUBCELL STATE
    Vaggregate_constant2*          TOPp;
    
    // CREATORS
    Vaggregate_constant2__Syms(Vaggregate_constant2* topp, const char* namep);
    ~Vaggregate_constant2__Syms() {}
    
    // METHODS
    inline const char* name() { return __Vm_namep; }
    
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
