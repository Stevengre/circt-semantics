// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vfinish__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vfinish::Vfinish(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vfinish__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vfinish::Vfinish(const char* _vcname__)
    : Vfinish(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vfinish::~Vfinish() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vfinish___024root___eval_debug_assertions(Vfinish___024root* vlSelf);
#endif  // VL_DEBUG
void Vfinish___024root___eval_static(Vfinish___024root* vlSelf);
void Vfinish___024root___eval_initial(Vfinish___024root* vlSelf);
void Vfinish___024root___eval_settle(Vfinish___024root* vlSelf);
void Vfinish___024root___eval(Vfinish___024root* vlSelf);

void Vfinish::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vfinish::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vfinish___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vfinish___024root___eval_static(&(vlSymsp->TOP));
        Vfinish___024root___eval_initial(&(vlSymsp->TOP));
        Vfinish___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vfinish___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vfinish::eventsPending() { return false; }

uint64_t Vfinish::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vfinish::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vfinish___024root___eval_final(Vfinish___024root* vlSelf);

VL_ATTR_COLD void Vfinish::final() {
    Vfinish___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vfinish::hierName() const { return vlSymsp->name(); }
const char* Vfinish::modelName() const { return "Vfinish"; }
unsigned Vfinish::threads() const { return 1; }
void Vfinish::prepareClone() const { contextp()->prepareClone(); }
void Vfinish::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vfinish::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vfinish___024root__trace_decl_types(VerilatedVcd* tracep);

void Vfinish___024root__trace_init_top(Vfinish___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vfinish___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfinish___024root*>(voidSelf);
    Vfinish__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vfinish___024root__trace_decl_types(tracep);
    Vfinish___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vfinish___024root__trace_register(Vfinish___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vfinish::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vfinish::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vfinish___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
