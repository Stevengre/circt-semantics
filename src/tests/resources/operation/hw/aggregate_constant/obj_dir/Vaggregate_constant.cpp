// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vaggregate_constant__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vaggregate_constant::Vaggregate_constant(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vaggregate_constant__Syms(contextp(), _vcname__, this)}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vaggregate_constant::Vaggregate_constant(const char* _vcname__)
    : Vaggregate_constant(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vaggregate_constant::~Vaggregate_constant() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vaggregate_constant___024root___eval_debug_assertions(Vaggregate_constant___024root* vlSelf);
#endif  // VL_DEBUG
void Vaggregate_constant___024root___eval_static(Vaggregate_constant___024root* vlSelf);
void Vaggregate_constant___024root___eval_initial(Vaggregate_constant___024root* vlSelf);
void Vaggregate_constant___024root___eval_settle(Vaggregate_constant___024root* vlSelf);
void Vaggregate_constant___024root___eval(Vaggregate_constant___024root* vlSelf);

void Vaggregate_constant::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vaggregate_constant::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vaggregate_constant___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vaggregate_constant___024root___eval_static(&(vlSymsp->TOP));
        Vaggregate_constant___024root___eval_initial(&(vlSymsp->TOP));
        Vaggregate_constant___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vaggregate_constant___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vaggregate_constant::eventsPending() { return false; }

uint64_t Vaggregate_constant::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vaggregate_constant::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vaggregate_constant___024root___eval_final(Vaggregate_constant___024root* vlSelf);

VL_ATTR_COLD void Vaggregate_constant::final() {
    Vaggregate_constant___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vaggregate_constant::hierName() const { return vlSymsp->name(); }
const char* Vaggregate_constant::modelName() const { return "Vaggregate_constant"; }
unsigned Vaggregate_constant::threads() const { return 1; }
void Vaggregate_constant::prepareClone() const { contextp()->prepareClone(); }
void Vaggregate_constant::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vaggregate_constant::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vaggregate_constant___024root__trace_decl_types(VerilatedVcd* tracep);

void Vaggregate_constant___024root__trace_init_top(Vaggregate_constant___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vaggregate_constant___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vaggregate_constant___024root*>(voidSelf);
    Vaggregate_constant__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vaggregate_constant___024root__trace_decl_types(tracep);
    Vaggregate_constant___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vaggregate_constant___024root__trace_register(Vaggregate_constant___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vaggregate_constant::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vaggregate_constant::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vaggregate_constant___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
