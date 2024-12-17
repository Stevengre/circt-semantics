// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vor__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vor::Vor(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vor__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vor::Vor(const char* _vcname__)
    : Vor(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vor::~Vor() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vor___024root___eval_debug_assertions(Vor___024root* vlSelf);
#endif  // VL_DEBUG
void Vor___024root___eval_static(Vor___024root* vlSelf);
void Vor___024root___eval_initial(Vor___024root* vlSelf);
void Vor___024root___eval_settle(Vor___024root* vlSelf);
void Vor___024root___eval(Vor___024root* vlSelf);

void Vor::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vor::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vor___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vor___024root___eval_static(&(vlSymsp->TOP));
        Vor___024root___eval_initial(&(vlSymsp->TOP));
        Vor___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vor___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vor::eventsPending() { return false; }

uint64_t Vor::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vor::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vor___024root___eval_final(Vor___024root* vlSelf);

VL_ATTR_COLD void Vor::final() {
    Vor___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vor::hierName() const { return vlSymsp->name(); }
const char* Vor::modelName() const { return "Vor"; }
unsigned Vor::threads() const { return 1; }
void Vor::prepareClone() const { contextp()->prepareClone(); }
void Vor::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vor::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vor___024root__trace_decl_types(VerilatedVcd* tracep);

void Vor___024root__trace_init_top(Vor___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vor___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vor___024root*>(voidSelf);
    Vor__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vor___024root__trace_decl_types(tracep);
    Vor___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vor___024root__trace_register(Vor___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vor::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vor::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vor___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
