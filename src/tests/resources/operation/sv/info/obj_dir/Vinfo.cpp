// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vinfo__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vinfo::Vinfo(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vinfo__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , a{vlSymsp->TOP.a}
    , b{vlSymsp->TOP.b}
    , result{vlSymsp->TOP.result}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vinfo::Vinfo(const char* _vcname__)
    : Vinfo(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vinfo::~Vinfo() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vinfo___024root___eval_debug_assertions(Vinfo___024root* vlSelf);
#endif  // VL_DEBUG
void Vinfo___024root___eval_static(Vinfo___024root* vlSelf);
void Vinfo___024root___eval_initial(Vinfo___024root* vlSelf);
void Vinfo___024root___eval_settle(Vinfo___024root* vlSelf);
void Vinfo___024root___eval(Vinfo___024root* vlSelf);

void Vinfo::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vinfo::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vinfo___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vinfo___024root___eval_static(&(vlSymsp->TOP));
        Vinfo___024root___eval_initial(&(vlSymsp->TOP));
        Vinfo___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vinfo___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vinfo::eventsPending() { return false; }

uint64_t Vinfo::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vinfo::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vinfo___024root___eval_final(Vinfo___024root* vlSelf);

VL_ATTR_COLD void Vinfo::final() {
    Vinfo___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vinfo::hierName() const { return vlSymsp->name(); }
const char* Vinfo::modelName() const { return "Vinfo"; }
unsigned Vinfo::threads() const { return 1; }
void Vinfo::prepareClone() const { contextp()->prepareClone(); }
void Vinfo::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vinfo::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vinfo___024root__trace_decl_types(VerilatedVcd* tracep);

void Vinfo___024root__trace_init_top(Vinfo___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vinfo___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vinfo___024root*>(voidSelf);
    Vinfo__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vinfo___024root__trace_decl_types(tracep);
    Vinfo___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vinfo___024root__trace_register(Vinfo___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vinfo::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vinfo::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vinfo___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
