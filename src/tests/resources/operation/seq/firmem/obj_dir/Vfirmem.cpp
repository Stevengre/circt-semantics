// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vfirmem__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vfirmem::Vfirmem(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vfirmem__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , reset{vlSymsp->TOP.reset}
    , data_in{vlSymsp->TOP.data_in}
    , addr{vlSymsp->TOP.addr}
    , mode{vlSymsp->TOP.mode}
    , read_out{vlSymsp->TOP.read_out}
    , rw_out{vlSymsp->TOP.rw_out}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vfirmem::Vfirmem(const char* _vcname__)
    : Vfirmem(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vfirmem::~Vfirmem() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vfirmem___024root___eval_debug_assertions(Vfirmem___024root* vlSelf);
#endif  // VL_DEBUG
void Vfirmem___024root___eval_static(Vfirmem___024root* vlSelf);
void Vfirmem___024root___eval_initial(Vfirmem___024root* vlSelf);
void Vfirmem___024root___eval_settle(Vfirmem___024root* vlSelf);
void Vfirmem___024root___eval(Vfirmem___024root* vlSelf);

void Vfirmem::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vfirmem::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vfirmem___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vfirmem___024root___eval_static(&(vlSymsp->TOP));
        Vfirmem___024root___eval_initial(&(vlSymsp->TOP));
        Vfirmem___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vfirmem___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vfirmem::eventsPending() { return false; }

uint64_t Vfirmem::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vfirmem::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vfirmem___024root___eval_final(Vfirmem___024root* vlSelf);

VL_ATTR_COLD void Vfirmem::final() {
    Vfirmem___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vfirmem::hierName() const { return vlSymsp->name(); }
const char* Vfirmem::modelName() const { return "Vfirmem"; }
unsigned Vfirmem::threads() const { return 1; }
void Vfirmem::prepareClone() const { contextp()->prepareClone(); }
void Vfirmem::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vfirmem::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vfirmem___024root__trace_decl_types(VerilatedVcd* tracep);

void Vfirmem___024root__trace_init_top(Vfirmem___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vfirmem___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfirmem___024root*>(voidSelf);
    Vfirmem__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vfirmem___024root__trace_decl_types(tracep);
    Vfirmem___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vfirmem___024root__trace_register(Vfirmem___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vfirmem::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vfirmem::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vfirmem___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
