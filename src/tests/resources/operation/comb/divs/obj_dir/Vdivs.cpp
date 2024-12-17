// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vdivs__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vdivs::Vdivs(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vdivs__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vdivs::Vdivs(const char* _vcname__)
    : Vdivs(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vdivs::~Vdivs() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vdivs___024root___eval_debug_assertions(Vdivs___024root* vlSelf);
#endif  // VL_DEBUG
void Vdivs___024root___eval_static(Vdivs___024root* vlSelf);
void Vdivs___024root___eval_initial(Vdivs___024root* vlSelf);
void Vdivs___024root___eval_settle(Vdivs___024root* vlSelf);
void Vdivs___024root___eval(Vdivs___024root* vlSelf);

void Vdivs::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vdivs::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vdivs___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vdivs___024root___eval_static(&(vlSymsp->TOP));
        Vdivs___024root___eval_initial(&(vlSymsp->TOP));
        Vdivs___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vdivs___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vdivs::eventsPending() { return false; }

uint64_t Vdivs::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vdivs::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vdivs___024root___eval_final(Vdivs___024root* vlSelf);

VL_ATTR_COLD void Vdivs::final() {
    Vdivs___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vdivs::hierName() const { return vlSymsp->name(); }
const char* Vdivs::modelName() const { return "Vdivs"; }
unsigned Vdivs::threads() const { return 1; }
void Vdivs::prepareClone() const { contextp()->prepareClone(); }
void Vdivs::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vdivs::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vdivs___024root__trace_decl_types(VerilatedVcd* tracep);

void Vdivs___024root__trace_init_top(Vdivs___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vdivs___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vdivs___024root*>(voidSelf);
    Vdivs__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vdivs___024root__trace_decl_types(tracep);
    Vdivs___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vdivs___024root__trace_register(Vdivs___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vdivs::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vdivs::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vdivs___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
