// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vadd__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vadd::Vadd(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vadd__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vadd::Vadd(const char* _vcname__)
    : Vadd(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vadd::~Vadd() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vadd___024root___eval_debug_assertions(Vadd___024root* vlSelf);
#endif  // VL_DEBUG
void Vadd___024root___eval_static(Vadd___024root* vlSelf);
void Vadd___024root___eval_initial(Vadd___024root* vlSelf);
void Vadd___024root___eval_settle(Vadd___024root* vlSelf);
void Vadd___024root___eval(Vadd___024root* vlSelf);

void Vadd::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vadd::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vadd___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vadd___024root___eval_static(&(vlSymsp->TOP));
        Vadd___024root___eval_initial(&(vlSymsp->TOP));
        Vadd___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vadd___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vadd::eventsPending() { return false; }

uint64_t Vadd::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vadd::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vadd___024root___eval_final(Vadd___024root* vlSelf);

VL_ATTR_COLD void Vadd::final() {
    Vadd___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vadd::hierName() const { return vlSymsp->name(); }
const char* Vadd::modelName() const { return "Vadd"; }
unsigned Vadd::threads() const { return 1; }
void Vadd::prepareClone() const { contextp()->prepareClone(); }
void Vadd::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vadd::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vadd___024root__trace_decl_types(VerilatedVcd* tracep);

void Vadd___024root__trace_init_top(Vadd___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vadd___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vadd___024root*>(voidSelf);
    Vadd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vadd___024root__trace_decl_types(tracep);
    Vadd___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vadd___024root__trace_register(Vadd___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vadd::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vadd::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vadd___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
