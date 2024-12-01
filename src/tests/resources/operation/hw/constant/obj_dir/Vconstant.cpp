// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vconstant__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vconstant::Vconstant(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vconstant__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vconstant::Vconstant(const char* _vcname__)
    : Vconstant(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vconstant::~Vconstant() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vconstant___024root___eval_debug_assertions(Vconstant___024root* vlSelf);
#endif  // VL_DEBUG
void Vconstant___024root___eval_static(Vconstant___024root* vlSelf);
void Vconstant___024root___eval_initial(Vconstant___024root* vlSelf);
void Vconstant___024root___eval_settle(Vconstant___024root* vlSelf);
void Vconstant___024root___eval(Vconstant___024root* vlSelf);

void Vconstant::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vconstant::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vconstant___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vconstant___024root___eval_static(&(vlSymsp->TOP));
        Vconstant___024root___eval_initial(&(vlSymsp->TOP));
        Vconstant___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vconstant___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vconstant::eventsPending() { return false; }

uint64_t Vconstant::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vconstant::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vconstant___024root___eval_final(Vconstant___024root* vlSelf);

VL_ATTR_COLD void Vconstant::final() {
    Vconstant___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vconstant::hierName() const { return vlSymsp->name(); }
const char* Vconstant::modelName() const { return "Vconstant"; }
unsigned Vconstant::threads() const { return 1; }
void Vconstant::prepareClone() const { contextp()->prepareClone(); }
void Vconstant::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vconstant::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vconstant___024root__trace_decl_types(VerilatedVcd* tracep);

void Vconstant___024root__trace_init_top(Vconstant___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vconstant___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vconstant___024root*>(voidSelf);
    Vconstant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vconstant___024root__trace_decl_types(tracep);
    Vconstant___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vconstant___024root__trace_register(Vconstant___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vconstant::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vconstant::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vconstant___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
