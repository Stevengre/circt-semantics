from pyk.ktool.kprint import _kast, KAstInput, KAstOutput, KPrint
from pyk.kore.parser import KoreParser
from pyk.kore.prelude import inj, top_cell_initializer, SORT_K_ITEM, kseq
from pyk.kore.syntax import SortApp, App, DV, String, Kore, Pattern
from pyk.ktool.krun import KRun, _krun, llvm_interpret, KRunOutput
from pyk.kore.tools import kore_print, PrintOutput
from pyk.konvert import _kore_to_kast
from pyk.kast.pretty import PrettyPrinter
from pyk.kast.outer import KDefinition
from pathlib import Path
import json

pgm_text = '''
#loc = loc("<stdin>":4:11)
#loc1 = loc("<stdin>":5:11)
#loc2 = loc("src/main/scala/Main.scala":14:16)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i1, %arg1: i1, %arg2: i8, %arg3: i8):
    %0 = "comb.add"(%arg2, %arg3) {sv.namehint = "_io_out_T_1"} : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {argLocs = [#loc, #loc1, #loc2, #loc2], argNames = ["clock", "reset", "io_a", "io_b"], comment = "", function_type = (i1, i1, i8, i8) -> i8, parameters = [], resultLocs = [#loc2], resultNames = ["io_out"], sym_name = "Adder"} : () -> ()
}) : () -> ()
'''.strip()

kompiled = 'circt-kompiled'

pgm_kore = _kast(definition_dir=kompiled, input='program',
                 output='kore', expression=pgm_text).stdout
pgm = KoreParser(pgm_kore).pattern()

ctrl_kore = _kast(definition_dir=kompiled, input=KAstInput.PROGRAM, output=KAstOutput.KORE,
                  expression='circtTest @Adder(0,0,1,2)', sort='Control').stdout
ctrl = KoreParser(ctrl_kore).pattern()
# print(ctrl)


init_pattern = top_cell_initializer({
    '$PGM': inj(SortApp('SortTopLevel'), SORT_K_ITEM, pgm),
    '$Control': inj(SortApp('SortControl'), SORT_K_ITEM, ctrl),
})

krun = KRun(definition_dir=Path(kompiled))

# state = llvm_interpret(pattern=init_pattern, definition_dir=kompiled, depth=0)
state = krun.run_pattern(pattern=init_pattern, depth=0)
init = state

# state = llvm_interpret(pattern=state, definition_dir=kompiled)
state = krun.run_pattern(pattern=state)


init = json.loads(init.json)
init['args'][1]['args'][4] = state.dict['args'][1]['args'][4]
init2 = Pattern.from_dict(init)

state = krun.run_pattern(init2)
print(kore_print(state, definition_dir=kompiled, output=PrintOutput.PRETTY))
