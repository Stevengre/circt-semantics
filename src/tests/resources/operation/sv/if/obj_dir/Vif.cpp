// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vif__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vif::Vif(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vif__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vif::Vif(const char* _vcname__)
    : Vif(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vif::~Vif() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vif___024root___eval_debug_assertions(Vif___024root* vlSelf);
#endif  // VL_DEBUG
void Vif___024root___eval_static(Vif___024root* vlSelf);
void Vif___024root___eval_initial(Vif___024root* vlSelf);
void Vif___024root___eval_settle(Vif___024root* vlSelf);
void Vif___024root___eval(Vif___024root* vlSelf);

void Vif::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vif::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vif___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vif___024root___eval_static(&(vlSymsp->TOP));
        Vif___024root___eval_initial(&(vlSymsp->TOP));
        Vif___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vif___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vif::eventsPending() { return false; }

uint64_t Vif::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vif::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vif___024root___eval_final(Vif___024root* vlSelf);

VL_ATTR_COLD void Vif::final() {
    Vif___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vif::hierName() const { return vlSymsp->name(); }
const char* Vif::modelName() const { return "Vif"; }
unsigned Vif::threads() const { return 1; }
void Vif::prepareClone() const { contextp()->prepareClone(); }
void Vif::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vif::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vif___024root__trace_decl_types(VerilatedVcd* tracep);

void Vif___024root__trace_init_top(Vif___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vif___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vif___024root*>(voidSelf);
    Vif__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vif___024root__trace_decl_types(tracep);
    Vif___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vif___024root__trace_register(Vif___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vif::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vif::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vif___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
