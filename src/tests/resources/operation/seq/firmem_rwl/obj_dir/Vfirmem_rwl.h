// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VFIRMEM_RWL_H_
#define _VFIRMEM_RWL_H_  // guard

#include "verilated.h"

//==========

class Vfirmem_rwl__Syms;
class Vfirmem_rwl_VerilatedVcd;


//----------

VL_MODULE(Vfirmem_rwl) {
  public:
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(clk,0,0);
    VL_IN8(data_in_w,7,0);
    VL_IN8(data_in_rw,7,0);
    VL_IN8(addr_r,1,0);
    VL_IN8(addr_w,1,0);
    VL_IN8(addr_rw,1,0);
    VL_IN8(mode,0,0);
    VL_IN8(enable_r,0,0);
    VL_IN8(enable_w,0,0);
    VL_IN8(enable_rw,0,0);
    VL_OUT8(read_out,7,0);
    VL_OUT8(rw_out,7,0);
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    CData/*0:0*/ Foo__DOT__memory_ext__DOT___R0_en_d0;
    CData/*1:0*/ Foo__DOT__memory_ext__DOT___R0_addr_d0;
    CData/*1:0*/ Foo__DOT__memory_ext__DOT___RW0_raddr_d0;
    CData/*0:0*/ Foo__DOT__memory_ext__DOT___RW0_ren_d0;
    CData/*0:0*/ Foo__DOT__memory_ext__DOT___RW0_rmode_d0;
    CData/*7:0*/ Foo__DOT__memory_ext__DOT__Memory[4];
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    CData/*0:0*/ __Vclklast__TOP__clk;
    CData/*0:0*/ __Vm_traceActivity[2];
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    Vfirmem_rwl__Syms* __VlSymsp;  // Symbol table
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vfirmem_rwl);  ///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible with respect to DPI scope names.
    Vfirmem_rwl(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~Vfirmem_rwl();
    /// Trace signals in the model; called by application code
    void trace(VerilatedVcdC* tfp, int levels, int options = 0);
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval() { eval_step(); }
    /// Evaluate when calling multiple units/models per time step.
    void eval_step();
    /// Evaluate at end of a timestep for tracing, when using eval_step().
    /// Application must call after all eval() and before time changes.
    void eval_end_step() {}
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(Vfirmem_rwl__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(Vfirmem_rwl__Syms* symsp, bool first);
  private:
    static QData _change_request(Vfirmem_rwl__Syms* __restrict vlSymsp);
    static QData _change_request_1(Vfirmem_rwl__Syms* __restrict vlSymsp);
    void _ctor_var_reset() VL_ATTR_COLD;
  public:
    static void _eval(Vfirmem_rwl__Syms* __restrict vlSymsp);
  private:
#ifdef VL_DEBUG
    void _eval_debug_assertions();
#endif  // VL_DEBUG
  public:
    static void _eval_initial(Vfirmem_rwl__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _eval_settle(Vfirmem_rwl__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _sequent__TOP__1(Vfirmem_rwl__Syms* __restrict vlSymsp);
    static void _settle__TOP__2(Vfirmem_rwl__Syms* __restrict vlSymsp) VL_ATTR_COLD;
  private:
    static void traceChgSub0(void* userp, VerilatedVcd* tracep);
    static void traceChgTop0(void* userp, VerilatedVcd* tracep);
    static void traceCleanup(void* userp, VerilatedVcd* /*unused*/);
    static void traceFullSub0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceFullTop0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInitSub0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInitTop(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    void traceRegister(VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
