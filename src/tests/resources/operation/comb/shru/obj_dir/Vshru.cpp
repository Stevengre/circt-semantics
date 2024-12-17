// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vshru__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vshru::Vshru(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vshru__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vshru::Vshru(const char* _vcname__)
    : Vshru(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vshru::~Vshru() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vshru___024root___eval_debug_assertions(Vshru___024root* vlSelf);
#endif  // VL_DEBUG
void Vshru___024root___eval_static(Vshru___024root* vlSelf);
void Vshru___024root___eval_initial(Vshru___024root* vlSelf);
void Vshru___024root___eval_settle(Vshru___024root* vlSelf);
void Vshru___024root___eval(Vshru___024root* vlSelf);

void Vshru::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vshru::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vshru___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vshru___024root___eval_static(&(vlSymsp->TOP));
        Vshru___024root___eval_initial(&(vlSymsp->TOP));
        Vshru___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vshru___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vshru::eventsPending() { return false; }

uint64_t Vshru::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vshru::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vshru___024root___eval_final(Vshru___024root* vlSelf);

VL_ATTR_COLD void Vshru::final() {
    Vshru___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vshru::hierName() const { return vlSymsp->name(); }
const char* Vshru::modelName() const { return "Vshru"; }
unsigned Vshru::threads() const { return 1; }
void Vshru::prepareClone() const { contextp()->prepareClone(); }
void Vshru::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vshru::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vshru___024root__trace_decl_types(VerilatedVcd* tracep);

void Vshru___024root__trace_init_top(Vshru___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vshru___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vshru___024root*>(voidSelf);
    Vshru__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vshru___024root__trace_decl_types(tracep);
    Vshru___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vshru___024root__trace_register(Vshru___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vshru::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vshru::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vshru___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
