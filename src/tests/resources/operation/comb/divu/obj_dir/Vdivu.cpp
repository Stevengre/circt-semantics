// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vdivu__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vdivu::Vdivu(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vdivu__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vdivu::Vdivu(const char* _vcname__)
    : Vdivu(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vdivu::~Vdivu() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vdivu___024root___eval_debug_assertions(Vdivu___024root* vlSelf);
#endif  // VL_DEBUG
void Vdivu___024root___eval_static(Vdivu___024root* vlSelf);
void Vdivu___024root___eval_initial(Vdivu___024root* vlSelf);
void Vdivu___024root___eval_settle(Vdivu___024root* vlSelf);
void Vdivu___024root___eval(Vdivu___024root* vlSelf);

void Vdivu::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vdivu::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vdivu___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vdivu___024root___eval_static(&(vlSymsp->TOP));
        Vdivu___024root___eval_initial(&(vlSymsp->TOP));
        Vdivu___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vdivu___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vdivu::eventsPending() { return false; }

uint64_t Vdivu::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vdivu::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vdivu___024root___eval_final(Vdivu___024root* vlSelf);

VL_ATTR_COLD void Vdivu::final() {
    Vdivu___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vdivu::hierName() const { return vlSymsp->name(); }
const char* Vdivu::modelName() const { return "Vdivu"; }
unsigned Vdivu::threads() const { return 1; }
void Vdivu::prepareClone() const { contextp()->prepareClone(); }
void Vdivu::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vdivu::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vdivu___024root__trace_decl_types(VerilatedVcd* tracep);

void Vdivu___024root__trace_init_top(Vdivu___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vdivu___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vdivu___024root*>(voidSelf);
    Vdivu__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vdivu___024root__trace_decl_types(tracep);
    Vdivu___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vdivu___024root__trace_register(Vdivu___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vdivu::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vdivu::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vdivu___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
