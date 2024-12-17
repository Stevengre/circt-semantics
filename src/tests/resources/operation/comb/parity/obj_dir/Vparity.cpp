// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vparity__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vparity::Vparity(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vparity__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vparity::Vparity(const char* _vcname__)
    : Vparity(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vparity::~Vparity() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vparity___024root___eval_debug_assertions(Vparity___024root* vlSelf);
#endif  // VL_DEBUG
void Vparity___024root___eval_static(Vparity___024root* vlSelf);
void Vparity___024root___eval_initial(Vparity___024root* vlSelf);
void Vparity___024root___eval_settle(Vparity___024root* vlSelf);
void Vparity___024root___eval(Vparity___024root* vlSelf);

void Vparity::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vparity::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vparity___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vparity___024root___eval_static(&(vlSymsp->TOP));
        Vparity___024root___eval_initial(&(vlSymsp->TOP));
        Vparity___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vparity___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vparity::eventsPending() { return false; }

uint64_t Vparity::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vparity::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vparity___024root___eval_final(Vparity___024root* vlSelf);

VL_ATTR_COLD void Vparity::final() {
    Vparity___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vparity::hierName() const { return vlSymsp->name(); }
const char* Vparity::modelName() const { return "Vparity"; }
unsigned Vparity::threads() const { return 1; }
void Vparity::prepareClone() const { contextp()->prepareClone(); }
void Vparity::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vparity::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vparity___024root__trace_decl_types(VerilatedVcd* tracep);

void Vparity___024root__trace_init_top(Vparity___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vparity___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vparity___024root*>(voidSelf);
    Vparity__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vparity___024root__trace_decl_types(tracep);
    Vparity___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vparity___024root__trace_register(Vparity___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vparity::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vparity::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vparity___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
