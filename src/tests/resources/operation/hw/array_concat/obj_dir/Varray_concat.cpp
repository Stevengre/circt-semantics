// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Varray_concat__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Varray_concat::Varray_concat(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Varray_concat__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , c{vlSymsp->TOP.c}
    , d{vlSymsp->TOP.d}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Varray_concat::Varray_concat(const char* _vcname__)
    : Varray_concat(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Varray_concat::~Varray_concat() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Varray_concat___024root___eval_debug_assertions(Varray_concat___024root* vlSelf);
#endif  // VL_DEBUG
void Varray_concat___024root___eval_static(Varray_concat___024root* vlSelf);
void Varray_concat___024root___eval_initial(Varray_concat___024root* vlSelf);
void Varray_concat___024root___eval_settle(Varray_concat___024root* vlSelf);
void Varray_concat___024root___eval(Varray_concat___024root* vlSelf);

void Varray_concat::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Varray_concat::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Varray_concat___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Varray_concat___024root___eval_static(&(vlSymsp->TOP));
        Varray_concat___024root___eval_initial(&(vlSymsp->TOP));
        Varray_concat___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Varray_concat___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Varray_concat::eventsPending() { return false; }

uint64_t Varray_concat::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Varray_concat::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Varray_concat___024root___eval_final(Varray_concat___024root* vlSelf);

VL_ATTR_COLD void Varray_concat::final() {
    Varray_concat___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Varray_concat::hierName() const { return vlSymsp->name(); }
const char* Varray_concat::modelName() const { return "Varray_concat"; }
unsigned Varray_concat::threads() const { return 1; }
void Varray_concat::prepareClone() const { contextp()->prepareClone(); }
void Varray_concat::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Varray_concat::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Varray_concat___024root__trace_decl_types(VerilatedVcd* tracep);

void Varray_concat___024root__trace_init_top(Varray_concat___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Varray_concat___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Varray_concat___024root*>(voidSelf);
    Varray_concat__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Varray_concat___024root__trace_decl_types(tracep);
    Varray_concat___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Varray_concat___024root__trace_register(Varray_concat___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Varray_concat::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Varray_concat::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Varray_concat___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
