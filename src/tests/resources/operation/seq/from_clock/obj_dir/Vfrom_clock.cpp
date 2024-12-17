// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vfrom_clock__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vfrom_clock::Vfrom_clock(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vfrom_clock__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vfrom_clock::Vfrom_clock(const char* _vcname__)
    : Vfrom_clock(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vfrom_clock::~Vfrom_clock() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vfrom_clock___024root___eval_debug_assertions(Vfrom_clock___024root* vlSelf);
#endif  // VL_DEBUG
void Vfrom_clock___024root___eval_static(Vfrom_clock___024root* vlSelf);
void Vfrom_clock___024root___eval_initial(Vfrom_clock___024root* vlSelf);
void Vfrom_clock___024root___eval_settle(Vfrom_clock___024root* vlSelf);
void Vfrom_clock___024root___eval(Vfrom_clock___024root* vlSelf);

void Vfrom_clock::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vfrom_clock::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vfrom_clock___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vfrom_clock___024root___eval_static(&(vlSymsp->TOP));
        Vfrom_clock___024root___eval_initial(&(vlSymsp->TOP));
        Vfrom_clock___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vfrom_clock___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vfrom_clock::eventsPending() { return false; }

uint64_t Vfrom_clock::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vfrom_clock::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vfrom_clock___024root___eval_final(Vfrom_clock___024root* vlSelf);

VL_ATTR_COLD void Vfrom_clock::final() {
    Vfrom_clock___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vfrom_clock::hierName() const { return vlSymsp->name(); }
const char* Vfrom_clock::modelName() const { return "Vfrom_clock"; }
unsigned Vfrom_clock::threads() const { return 1; }
void Vfrom_clock::prepareClone() const { contextp()->prepareClone(); }
void Vfrom_clock::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vfrom_clock::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vfrom_clock___024root__trace_decl_types(VerilatedVcd* tracep);

void Vfrom_clock___024root__trace_init_top(Vfrom_clock___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vfrom_clock___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfrom_clock___024root*>(voidSelf);
    Vfrom_clock__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vfrom_clock___024root__trace_decl_types(tracep);
    Vfrom_clock___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vfrom_clock___024root__trace_register(Vfrom_clock___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vfrom_clock::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vfrom_clock::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vfrom_clock___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
