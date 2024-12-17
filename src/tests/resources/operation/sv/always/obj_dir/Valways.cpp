// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Valways__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Valways::Valways(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Valways__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , result{vlSymsp->TOP.result}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Valways::Valways(const char* _vcname__)
    : Valways(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Valways::~Valways() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Valways___024root___eval_debug_assertions(Valways___024root* vlSelf);
#endif  // VL_DEBUG
void Valways___024root___eval_static(Valways___024root* vlSelf);
void Valways___024root___eval_initial(Valways___024root* vlSelf);
void Valways___024root___eval_settle(Valways___024root* vlSelf);
void Valways___024root___eval(Valways___024root* vlSelf);

void Valways::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Valways::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Valways___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Valways___024root___eval_static(&(vlSymsp->TOP));
        Valways___024root___eval_initial(&(vlSymsp->TOP));
        Valways___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Valways___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Valways::eventsPending() { return false; }

uint64_t Valways::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Valways::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Valways___024root___eval_final(Valways___024root* vlSelf);

VL_ATTR_COLD void Valways::final() {
    Valways___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Valways::hierName() const { return vlSymsp->name(); }
const char* Valways::modelName() const { return "Valways"; }
unsigned Valways::threads() const { return 1; }
void Valways::prepareClone() const { contextp()->prepareClone(); }
void Valways::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Valways::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Valways___024root__trace_decl_types(VerilatedVcd* tracep);

void Valways___024root__trace_init_top(Valways___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Valways___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Valways___024root*>(voidSelf);
    Valways__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Valways___024root__trace_decl_types(tracep);
    Valways___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Valways___024root__trace_register(Valways___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Valways::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Valways::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Valways___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
