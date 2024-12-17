// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Verror__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Verror::Verror(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Verror__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Verror::Verror(const char* _vcname__)
    : Verror(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Verror::~Verror() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Verror___024root___eval_debug_assertions(Verror___024root* vlSelf);
#endif  // VL_DEBUG
void Verror___024root___eval_static(Verror___024root* vlSelf);
void Verror___024root___eval_initial(Verror___024root* vlSelf);
void Verror___024root___eval_settle(Verror___024root* vlSelf);
void Verror___024root___eval(Verror___024root* vlSelf);

void Verror::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Verror::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Verror___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Verror___024root___eval_static(&(vlSymsp->TOP));
        Verror___024root___eval_initial(&(vlSymsp->TOP));
        Verror___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Verror___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Verror::eventsPending() { return false; }

uint64_t Verror::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Verror::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Verror___024root___eval_final(Verror___024root* vlSelf);

VL_ATTR_COLD void Verror::final() {
    Verror___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Verror::hierName() const { return vlSymsp->name(); }
const char* Verror::modelName() const { return "Verror"; }
unsigned Verror::threads() const { return 1; }
void Verror::prepareClone() const { contextp()->prepareClone(); }
void Verror::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Verror::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Verror___024root__trace_decl_types(VerilatedVcd* tracep);

void Verror___024root__trace_init_top(Verror___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Verror___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Verror___024root*>(voidSelf);
    Verror__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Verror___024root__trace_decl_types(tracep);
    Verror___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Verror___024root__trace_register(Verror___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Verror::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Verror::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Verror___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
