// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vinstance__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vinstance::Vinstance(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vinstance__Syms(contextp(), _vcname__, this)}
    , io_a{vlSymsp->TOP.io_a}
    , res_out2{vlSymsp->TOP.res_out2}
    , res_out1{vlSymsp->TOP.res_out1}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vinstance::Vinstance(const char* _vcname__)
    : Vinstance(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vinstance::~Vinstance() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vinstance___024root___eval_debug_assertions(Vinstance___024root* vlSelf);
#endif  // VL_DEBUG
void Vinstance___024root___eval_static(Vinstance___024root* vlSelf);
void Vinstance___024root___eval_initial(Vinstance___024root* vlSelf);
void Vinstance___024root___eval_settle(Vinstance___024root* vlSelf);
void Vinstance___024root___eval(Vinstance___024root* vlSelf);

void Vinstance::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vinstance::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vinstance___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vinstance___024root___eval_static(&(vlSymsp->TOP));
        Vinstance___024root___eval_initial(&(vlSymsp->TOP));
        Vinstance___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vinstance___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vinstance::eventsPending() { return false; }

uint64_t Vinstance::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vinstance::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vinstance___024root___eval_final(Vinstance___024root* vlSelf);

VL_ATTR_COLD void Vinstance::final() {
    Vinstance___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vinstance::hierName() const { return vlSymsp->name(); }
const char* Vinstance::modelName() const { return "Vinstance"; }
unsigned Vinstance::threads() const { return 1; }
void Vinstance::prepareClone() const { contextp()->prepareClone(); }
void Vinstance::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vinstance::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vinstance___024root__trace_decl_types(VerilatedVcd* tracep);

void Vinstance___024root__trace_init_top(Vinstance___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vinstance___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vinstance___024root*>(voidSelf);
    Vinstance__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vinstance___024root__trace_decl_types(tracep);
    Vinstance___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vinstance___024root__trace_register(Vinstance___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vinstance::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vinstance::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vinstance___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
