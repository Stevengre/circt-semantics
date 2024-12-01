// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vfirreg__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vfirreg::Vfirreg(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vfirreg__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , reset{vlSymsp->TOP.reset}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vfirreg::Vfirreg(const char* _vcname__)
    : Vfirreg(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vfirreg::~Vfirreg() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vfirreg___024root___eval_debug_assertions(Vfirreg___024root* vlSelf);
#endif  // VL_DEBUG
void Vfirreg___024root___eval_static(Vfirreg___024root* vlSelf);
void Vfirreg___024root___eval_initial(Vfirreg___024root* vlSelf);
void Vfirreg___024root___eval_settle(Vfirreg___024root* vlSelf);
void Vfirreg___024root___eval(Vfirreg___024root* vlSelf);

void Vfirreg::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vfirreg::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vfirreg___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vfirreg___024root___eval_static(&(vlSymsp->TOP));
        Vfirreg___024root___eval_initial(&(vlSymsp->TOP));
        Vfirreg___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vfirreg___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vfirreg::eventsPending() { return false; }

uint64_t Vfirreg::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vfirreg::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vfirreg___024root___eval_final(Vfirreg___024root* vlSelf);

VL_ATTR_COLD void Vfirreg::final() {
    Vfirreg___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vfirreg::hierName() const { return vlSymsp->name(); }
const char* Vfirreg::modelName() const { return "Vfirreg"; }
unsigned Vfirreg::threads() const { return 1; }
void Vfirreg::prepareClone() const { contextp()->prepareClone(); }
void Vfirreg::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vfirreg::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vfirreg___024root__trace_decl_types(VerilatedVcd* tracep);

void Vfirreg___024root__trace_init_top(Vfirreg___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vfirreg___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfirreg___024root*>(voidSelf);
    Vfirreg__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vfirreg___024root__trace_decl_types(tracep);
    Vfirreg___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vfirreg___024root__trace_register(Vfirreg___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vfirreg::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vfirreg::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vfirreg___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
