// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vmodu__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vmodu::Vmodu(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vmodu__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vmodu::Vmodu(const char* _vcname__)
    : Vmodu(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vmodu::~Vmodu() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vmodu___024root___eval_debug_assertions(Vmodu___024root* vlSelf);
#endif  // VL_DEBUG
void Vmodu___024root___eval_static(Vmodu___024root* vlSelf);
void Vmodu___024root___eval_initial(Vmodu___024root* vlSelf);
void Vmodu___024root___eval_settle(Vmodu___024root* vlSelf);
void Vmodu___024root___eval(Vmodu___024root* vlSelf);

void Vmodu::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vmodu::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vmodu___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vmodu___024root___eval_static(&(vlSymsp->TOP));
        Vmodu___024root___eval_initial(&(vlSymsp->TOP));
        Vmodu___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vmodu___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vmodu::eventsPending() { return false; }

uint64_t Vmodu::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vmodu::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vmodu___024root___eval_final(Vmodu___024root* vlSelf);

VL_ATTR_COLD void Vmodu::final() {
    Vmodu___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vmodu::hierName() const { return vlSymsp->name(); }
const char* Vmodu::modelName() const { return "Vmodu"; }
unsigned Vmodu::threads() const { return 1; }
void Vmodu::prepareClone() const { contextp()->prepareClone(); }
void Vmodu::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vmodu::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vmodu___024root__trace_decl_types(VerilatedVcd* tracep);

void Vmodu___024root__trace_init_top(Vmodu___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vmodu___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vmodu___024root*>(voidSelf);
    Vmodu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vmodu___024root__trace_decl_types(tracep);
    Vmodu___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vmodu___024root__trace_register(Vmodu___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vmodu::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vmodu::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vmodu___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
