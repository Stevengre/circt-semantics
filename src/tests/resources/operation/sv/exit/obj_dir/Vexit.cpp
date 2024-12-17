// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vexit__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vexit::Vexit(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vexit__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vexit::Vexit(const char* _vcname__)
    : Vexit(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vexit::~Vexit() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vexit___024root___eval_debug_assertions(Vexit___024root* vlSelf);
#endif  // VL_DEBUG
void Vexit___024root___eval_static(Vexit___024root* vlSelf);
void Vexit___024root___eval_initial(Vexit___024root* vlSelf);
void Vexit___024root___eval_settle(Vexit___024root* vlSelf);
void Vexit___024root___eval(Vexit___024root* vlSelf);

void Vexit::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vexit::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vexit___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vexit___024root___eval_static(&(vlSymsp->TOP));
        Vexit___024root___eval_initial(&(vlSymsp->TOP));
        Vexit___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vexit___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vexit::eventsPending() { return false; }

uint64_t Vexit::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vexit::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vexit___024root___eval_final(Vexit___024root* vlSelf);

VL_ATTR_COLD void Vexit::final() {
    Vexit___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vexit::hierName() const { return vlSymsp->name(); }
const char* Vexit::modelName() const { return "Vexit"; }
unsigned Vexit::threads() const { return 1; }
void Vexit::prepareClone() const { contextp()->prepareClone(); }
void Vexit::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vexit::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vexit___024root__trace_decl_types(VerilatedVcd* tracep);

void Vexit___024root__trace_init_top(Vexit___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vexit___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vexit___024root*>(voidSelf);
    Vexit__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vexit___024root__trace_decl_types(tracep);
    Vexit___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vexit___024root__trace_register(Vexit___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vexit::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vexit::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vexit___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
