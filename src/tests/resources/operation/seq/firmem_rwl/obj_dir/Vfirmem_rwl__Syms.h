// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef _VFIRMEM_RWL__SYMS_H_
#define _VFIRMEM_RWL__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODULE CLASSES
#include "Vfirmem_rwl.h"

// SYMS CLASS
class Vfirmem_rwl__Syms : public VerilatedSyms {
  public:
    
    // LOCAL STATE
    const char* __Vm_namep;
    bool __Vm_activity;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode;  ///< Used by trace routines when tracing multiple models
    bool __Vm_didInit;
    
    // SUBCELL STATE
    Vfirmem_rwl*                   TOPp;
    
    // CREATORS
    Vfirmem_rwl__Syms(Vfirmem_rwl* topp, const char* namep);
    ~Vfirmem_rwl__Syms() {}
    
    // METHODS
    inline const char* name() { return __Vm_namep; }
    
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
