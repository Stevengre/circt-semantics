// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vshrs__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vshrs::Vshrs(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vshrs__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vshrs::Vshrs(const char* _vcname__)
    : Vshrs(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vshrs::~Vshrs() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vshrs___024root___eval_debug_assertions(Vshrs___024root* vlSelf);
#endif  // VL_DEBUG
void Vshrs___024root___eval_static(Vshrs___024root* vlSelf);
void Vshrs___024root___eval_initial(Vshrs___024root* vlSelf);
void Vshrs___024root___eval_settle(Vshrs___024root* vlSelf);
void Vshrs___024root___eval(Vshrs___024root* vlSelf);

void Vshrs::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vshrs::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vshrs___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vshrs___024root___eval_static(&(vlSymsp->TOP));
        Vshrs___024root___eval_initial(&(vlSymsp->TOP));
        Vshrs___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vshrs___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vshrs::eventsPending() { return false; }

uint64_t Vshrs::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vshrs::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vshrs___024root___eval_final(Vshrs___024root* vlSelf);

VL_ATTR_COLD void Vshrs::final() {
    Vshrs___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vshrs::hierName() const { return vlSymsp->name(); }
const char* Vshrs::modelName() const { return "Vshrs"; }
unsigned Vshrs::threads() const { return 1; }
void Vshrs::prepareClone() const { contextp()->prepareClone(); }
void Vshrs::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vshrs::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vshrs___024root__trace_decl_types(VerilatedVcd* tracep);

void Vshrs___024root__trace_init_top(Vshrs___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vshrs___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vshrs___024root*>(voidSelf);
    Vshrs__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vshrs___024root__trace_decl_types(tracep);
    Vshrs___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vshrs___024root__trace_register(Vshrs___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vshrs::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vshrs::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vshrs___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
