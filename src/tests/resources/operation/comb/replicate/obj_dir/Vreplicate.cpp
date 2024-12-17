// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vreplicate__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vreplicate::Vreplicate(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vreplicate__Syms(contextp(), _vcname__, this)}
    , a{vlSymsp->TOP.a}
    , res{vlSymsp->TOP.res}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vreplicate::Vreplicate(const char* _vcname__)
    : Vreplicate(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vreplicate::~Vreplicate() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vreplicate___024root___eval_debug_assertions(Vreplicate___024root* vlSelf);
#endif  // VL_DEBUG
void Vreplicate___024root___eval_static(Vreplicate___024root* vlSelf);
void Vreplicate___024root___eval_initial(Vreplicate___024root* vlSelf);
void Vreplicate___024root___eval_settle(Vreplicate___024root* vlSelf);
void Vreplicate___024root___eval(Vreplicate___024root* vlSelf);

void Vreplicate::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vreplicate::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vreplicate___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vreplicate___024root___eval_static(&(vlSymsp->TOP));
        Vreplicate___024root___eval_initial(&(vlSymsp->TOP));
        Vreplicate___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vreplicate___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vreplicate::eventsPending() { return false; }

uint64_t Vreplicate::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vreplicate::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vreplicate___024root___eval_final(Vreplicate___024root* vlSelf);

VL_ATTR_COLD void Vreplicate::final() {
    Vreplicate___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vreplicate::hierName() const { return vlSymsp->name(); }
const char* Vreplicate::modelName() const { return "Vreplicate"; }
unsigned Vreplicate::threads() const { return 1; }
void Vreplicate::prepareClone() const { contextp()->prepareClone(); }
void Vreplicate::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vreplicate::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vreplicate___024root__trace_decl_types(VerilatedVcd* tracep);

void Vreplicate___024root__trace_init_top(Vreplicate___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vreplicate___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vreplicate___024root*>(voidSelf);
    Vreplicate__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vreplicate___024root__trace_decl_types(tracep);
    Vreplicate___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vreplicate___024root__trace_register(Vreplicate___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vreplicate::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vreplicate::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    (void)levels; (void)options; // Prevent unused variable warning
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vreplicate___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
