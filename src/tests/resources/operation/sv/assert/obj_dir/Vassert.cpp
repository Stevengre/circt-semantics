// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vassert__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vassert::Vassert(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vassert__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vassert::Vassert(const char* _vcname__)
    : Vassert(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vassert::~Vassert() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vassert___024root___eval_debug_assertions(Vassert___024root* vlSelf);
#endif  // VL_DEBUG
void Vassert___024root___eval_static(Vassert___024root* vlSelf);
void Vassert___024root___eval_initial(Vassert___024root* vlSelf);
void Vassert___024root___eval_settle(Vassert___024root* vlSelf);
void Vassert___024root___eval(Vassert___024root* vlSelf);

void Vassert::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vassert::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vassert___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vassert___024root___eval_static(&(vlSymsp->TOP));
        Vassert___024root___eval_initial(&(vlSymsp->TOP));
        Vassert___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vassert___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vassert::eventsPending() { return false; }

uint64_t Vassert::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vassert::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vassert___024root___eval_final(Vassert___024root* vlSelf);

VL_ATTR_COLD void Vassert::final() {
    Vassert___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vassert::hierName() const { return vlSymsp->name(); }
const char* Vassert::modelName() const { return "Vassert"; }
unsigned Vassert::threads() const { return 1; }
void Vassert::prepareClone() const { contextp()->prepareClone(); }
void Vassert::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vassert::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vassert___024root__trace_decl_types(VerilatedVcd* tracep);

void Vassert___024root__trace_init_top(Vassert___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vassert___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vassert___024root*>(voidSelf);
    Vassert__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vassert___024root__trace_decl_types(tracep);
    Vassert___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vassert___024root__trace_register(Vassert___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vassert::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vassert::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vassert___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
