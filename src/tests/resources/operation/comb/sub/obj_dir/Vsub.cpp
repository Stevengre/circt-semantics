// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vsub__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vsub::Vsub(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vsub__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vsub::Vsub(const char* _vcname__)
    : Vsub(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vsub::~Vsub() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vsub___024root___eval_debug_assertions(Vsub___024root* vlSelf);
#endif  // VL_DEBUG
void Vsub___024root___eval_static(Vsub___024root* vlSelf);
void Vsub___024root___eval_initial(Vsub___024root* vlSelf);
void Vsub___024root___eval_settle(Vsub___024root* vlSelf);
void Vsub___024root___eval(Vsub___024root* vlSelf);

void Vsub::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vsub::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vsub___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vsub___024root___eval_static(&(vlSymsp->TOP));
        Vsub___024root___eval_initial(&(vlSymsp->TOP));
        Vsub___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vsub___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vsub::eventsPending() { return false; }

uint64_t Vsub::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vsub::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vsub___024root___eval_final(Vsub___024root* vlSelf);

VL_ATTR_COLD void Vsub::final() {
    Vsub___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vsub::hierName() const { return vlSymsp->name(); }
const char* Vsub::modelName() const { return "Vsub"; }
unsigned Vsub::threads() const { return 1; }
void Vsub::prepareClone() const { contextp()->prepareClone(); }
void Vsub::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vsub::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vsub___024root__trace_decl_types(VerilatedVcd* tracep);

void Vsub___024root__trace_init_top(Vsub___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vsub___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vsub___024root*>(voidSelf);
    Vsub__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vsub___024root__trace_decl_types(tracep);
    Vsub___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vsub___024root__trace_register(Vsub___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vsub::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vsub::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vsub___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
