// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vfirmem_mask__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vfirmem_mask::Vfirmem_mask(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vfirmem_mask__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , data_in_w{vlSymsp->TOP.data_in_w}
    , data_in_rw{vlSymsp->TOP.data_in_rw}
    , addr_r{vlSymsp->TOP.addr_r}
    , addr_w{vlSymsp->TOP.addr_w}
    , addr_rw{vlSymsp->TOP.addr_rw}
    , mode{vlSymsp->TOP.mode}
    , enable_r{vlSymsp->TOP.enable_r}
    , enable_w{vlSymsp->TOP.enable_w}
    , enable_rw{vlSymsp->TOP.enable_rw}
    , mask_in{vlSymsp->TOP.mask_in}
    , rw_out{vlSymsp->TOP.rw_out}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
    contextp()->traceBaseModelCbAdd(
        [this](VerilatedTraceBaseC* tfp, int levels, int options) { traceBaseModel(tfp, levels, options); });
}

Vfirmem_mask::Vfirmem_mask(const char* _vcname__)
    : Vfirmem_mask(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vfirmem_mask::~Vfirmem_mask() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vfirmem_mask___024root___eval_debug_assertions(Vfirmem_mask___024root* vlSelf);
#endif  // VL_DEBUG
void Vfirmem_mask___024root___eval_static(Vfirmem_mask___024root* vlSelf);
void Vfirmem_mask___024root___eval_initial(Vfirmem_mask___024root* vlSelf);
void Vfirmem_mask___024root___eval_settle(Vfirmem_mask___024root* vlSelf);
void Vfirmem_mask___024root___eval(Vfirmem_mask___024root* vlSelf);

void Vfirmem_mask::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vfirmem_mask::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vfirmem_mask___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vfirmem_mask___024root___eval_static(&(vlSymsp->TOP));
        Vfirmem_mask___024root___eval_initial(&(vlSymsp->TOP));
        Vfirmem_mask___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vfirmem_mask___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vfirmem_mask::eventsPending() { return false; }

uint64_t Vfirmem_mask::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vfirmem_mask::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vfirmem_mask___024root___eval_final(Vfirmem_mask___024root* vlSelf);

VL_ATTR_COLD void Vfirmem_mask::final() {
    Vfirmem_mask___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vfirmem_mask::hierName() const { return vlSymsp->name(); }
const char* Vfirmem_mask::modelName() const { return "Vfirmem_mask"; }
unsigned Vfirmem_mask::threads() const { return 1; }
void Vfirmem_mask::prepareClone() const { contextp()->prepareClone(); }
void Vfirmem_mask::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vfirmem_mask::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vfirmem_mask___024root__trace_decl_types(VerilatedVcd* tracep);

void Vfirmem_mask___024root__trace_init_top(Vfirmem_mask___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vfirmem_mask___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vfirmem_mask___024root*>(voidSelf);
    Vfirmem_mask__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vfirmem_mask___024root__trace_decl_types(tracep);
    Vfirmem_mask___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vfirmem_mask___024root__trace_register(Vfirmem_mask___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vfirmem_mask::traceBaseModel(VerilatedTraceBaseC* tfp, int levels, int options) {
    (void)levels; (void)options;
    VerilatedVcdC* const stfp = dynamic_cast<VerilatedVcdC*>(tfp);
    if (VL_UNLIKELY(!stfp)) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vfirmem_mask::trace()' called on non-VerilatedVcdC object;"
            " use --trace-fst with VerilatedFst object, and --trace-vcd with VerilatedVcd object");
    }
    stfp->spTrace()->addModel(this);
    stfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vfirmem_mask___024root__trace_register(&(vlSymsp->TOP), stfp->spTrace());
}
