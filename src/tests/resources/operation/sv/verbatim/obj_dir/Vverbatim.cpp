// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vverbatim__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vverbatim::Vverbatim(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vverbatim__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vverbatim::Vverbatim(const char* _vcname__)
    : Vverbatim(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vverbatim::~Vverbatim() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vverbatim___024root___eval_debug_assertions(Vverbatim___024root* vlSelf);
#endif  // VL_DEBUG
void Vverbatim___024root___eval_static(Vverbatim___024root* vlSelf);
void Vverbatim___024root___eval_initial(Vverbatim___024root* vlSelf);
void Vverbatim___024root___eval_settle(Vverbatim___024root* vlSelf);
void Vverbatim___024root___eval(Vverbatim___024root* vlSelf);

void Vverbatim::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vverbatim::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vverbatim___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vverbatim___024root___eval_static(&(vlSymsp->TOP));
        Vverbatim___024root___eval_initial(&(vlSymsp->TOP));
        Vverbatim___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vverbatim___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vverbatim::eventsPending() { return false; }

uint64_t Vverbatim::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vverbatim::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vverbatim___024root___eval_final(Vverbatim___024root* vlSelf);

VL_ATTR_COLD void Vverbatim::final() {
    Vverbatim___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vverbatim::hierName() const { return vlSymsp->name(); }
const char* Vverbatim::modelName() const { return "Vverbatim"; }
unsigned Vverbatim::threads() const { return 1; }
void Vverbatim::prepareClone() const { contextp()->prepareClone(); }
void Vverbatim::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vverbatim::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vverbatim___024root__trace_decl_types(VerilatedVcd* tracep);

void Vverbatim___024root__trace_init_top(Vverbatim___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vverbatim___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vverbatim___024root*>(voidSelf);
    Vverbatim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vverbatim___024root__trace_decl_types(tracep);
    Vverbatim___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vverbatim___024root__trace_register(Vverbatim___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vverbatim::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vverbatim::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vverbatim___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
