// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vfor__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vfor::Vfor(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vfor__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vfor::Vfor(const char* _vcname__)
    : Vfor(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vfor::~Vfor() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vfor___024root___eval_debug_assertions(Vfor___024root* vlSelf);
#endif  // VL_DEBUG
void Vfor___024root___eval_static(Vfor___024root* vlSelf);
void Vfor___024root___eval_initial(Vfor___024root* vlSelf);
void Vfor___024root___eval_settle(Vfor___024root* vlSelf);
void Vfor___024root___eval(Vfor___024root* vlSelf);

void Vfor::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vfor::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vfor___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vfor___024root___eval_static(&(vlSymsp->TOP));
        Vfor___024root___eval_initial(&(vlSymsp->TOP));
        Vfor___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vfor___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vfor::eventsPending() { return false; }

uint64_t Vfor::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vfor::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vfor___024root___eval_final(Vfor___024root* vlSelf);

VL_ATTR_COLD void Vfor::final() {
    Vfor___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vfor::hierName() const { return vlSymsp->name(); }
const char* Vfor::modelName() const { return "Vfor"; }
unsigned Vfor::threads() const { return 1; }
void Vfor::prepareClone() const { contextp()->prepareClone(); }
void Vfor::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vfor::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vfor___024root__trace_decl_types(VerilatedVcd* tracep);

void Vfor___024root__trace_init_top(Vfor___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vfor___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfor___024root*>(voidSelf);
    Vfor__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vfor___024root__trace_decl_types(tracep);
    Vfor___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vfor___024root__trace_register(Vfor___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vfor::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vfor::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vfor___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
