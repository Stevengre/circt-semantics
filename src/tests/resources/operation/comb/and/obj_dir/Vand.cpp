// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vand__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vand::Vand(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vand__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vand::Vand(const char* _vcname__)
    : Vand(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vand::~Vand() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vand___024root___eval_debug_assertions(Vand___024root* vlSelf);
#endif  // VL_DEBUG
void Vand___024root___eval_static(Vand___024root* vlSelf);
void Vand___024root___eval_initial(Vand___024root* vlSelf);
void Vand___024root___eval_settle(Vand___024root* vlSelf);
void Vand___024root___eval(Vand___024root* vlSelf);

void Vand::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vand::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vand___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vand___024root___eval_static(&(vlSymsp->TOP));
        Vand___024root___eval_initial(&(vlSymsp->TOP));
        Vand___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vand___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vand::eventsPending() { return false; }

uint64_t Vand::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vand::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vand___024root___eval_final(Vand___024root* vlSelf);

VL_ATTR_COLD void Vand::final() {
    Vand___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vand::hierName() const { return vlSymsp->name(); }
const char* Vand::modelName() const { return "Vand"; }
unsigned Vand::threads() const { return 1; }
void Vand::prepareClone() const { contextp()->prepareClone(); }
void Vand::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vand::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vand___024root__trace_decl_types(VerilatedVcd* tracep);

void Vand___024root__trace_init_top(Vand___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vand___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vand___024root*>(voidSelf);
    Vand__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vand___024root__trace_decl_types(tracep);
    Vand___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vand___024root__trace_register(Vand___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vand::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vand::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vand___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
