// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vfatal__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vfatal::Vfatal(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vfatal__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vfatal::Vfatal(const char* _vcname__)
    : Vfatal(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vfatal::~Vfatal() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vfatal___024root___eval_debug_assertions(Vfatal___024root* vlSelf);
#endif  // VL_DEBUG
void Vfatal___024root___eval_static(Vfatal___024root* vlSelf);
void Vfatal___024root___eval_initial(Vfatal___024root* vlSelf);
void Vfatal___024root___eval_settle(Vfatal___024root* vlSelf);
void Vfatal___024root___eval(Vfatal___024root* vlSelf);

void Vfatal::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vfatal::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vfatal___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vfatal___024root___eval_static(&(vlSymsp->TOP));
        Vfatal___024root___eval_initial(&(vlSymsp->TOP));
        Vfatal___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vfatal___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vfatal::eventsPending() { return false; }

uint64_t Vfatal::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vfatal::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vfatal___024root___eval_final(Vfatal___024root* vlSelf);

VL_ATTR_COLD void Vfatal::final() {
    Vfatal___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vfatal::hierName() const { return vlSymsp->name(); }
const char* Vfatal::modelName() const { return "Vfatal"; }
unsigned Vfatal::threads() const { return 1; }
void Vfatal::prepareClone() const { contextp()->prepareClone(); }
void Vfatal::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vfatal::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vfatal___024root__trace_decl_types(VerilatedVcd* tracep);

void Vfatal___024root__trace_init_top(Vfatal___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vfatal___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfatal___024root*>(voidSelf);
    Vfatal__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vfatal___024root__trace_decl_types(tracep);
    Vfatal___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vfatal___024root__trace_register(Vfatal___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vfatal::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vfatal::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vfatal___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
