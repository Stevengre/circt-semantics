// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vmodule__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vmodule::Vmodule(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vmodule__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vmodule::Vmodule(const char* _vcname__)
    : Vmodule(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vmodule::~Vmodule() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vmodule___024root___eval_debug_assertions(Vmodule___024root* vlSelf);
#endif  // VL_DEBUG
void Vmodule___024root___eval_static(Vmodule___024root* vlSelf);
void Vmodule___024root___eval_initial(Vmodule___024root* vlSelf);
void Vmodule___024root___eval_settle(Vmodule___024root* vlSelf);
void Vmodule___024root___eval(Vmodule___024root* vlSelf);

void Vmodule::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vmodule::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vmodule___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vmodule___024root___eval_static(&(vlSymsp->TOP));
        Vmodule___024root___eval_initial(&(vlSymsp->TOP));
        Vmodule___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vmodule___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vmodule::eventsPending() { return false; }

uint64_t Vmodule::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vmodule::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vmodule___024root___eval_final(Vmodule___024root* vlSelf);

VL_ATTR_COLD void Vmodule::final() {
    Vmodule___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vmodule::hierName() const { return vlSymsp->name(); }
const char* Vmodule::modelName() const { return "Vmodule"; }
unsigned Vmodule::threads() const { return 1; }
void Vmodule::prepareClone() const { contextp()->prepareClone(); }
void Vmodule::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vmodule::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vmodule___024root__trace_decl_types(VerilatedVcd* tracep);

void Vmodule___024root__trace_init_top(Vmodule___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vmodule___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vmodule___024root*>(voidSelf);
    Vmodule__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vmodule___024root__trace_decl_types(tracep);
    Vmodule___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vmodule___024root__trace_register(Vmodule___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vmodule::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vmodule::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vmodule___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
