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

with open('./tests/1.mlir', 'r') as f:
    pgm_text = f.read()


kompiled = 'main-kompiled'

pgm_kore = _kast(definition_dir=kompiled, input='program', output='kore', expression=pgm_text).stdout
pgm = KoreParser(pgm_kore).pattern()
# print(pgm)

# ctrl_kore = _kast(definition_dir=kompiled, 
#                   input=KAstInput.PROGRAM,
#                   output=KAstOutput.KORE,
#                   expression='circtTest @Adder(0,0,1,2)',
#                   sort='Control').stdout
# ctrl = KoreParser(ctrl_kore).pattern()
# # print(ctrl)


init_pattern = top_cell_initializer({
    '$PGM': inj(SortApp('SortTopLevel'), SORT_K_ITEM, pgm),
    # '$Control': inj(SortApp('SortControl'), SORT_K_ITEM, ctrl),
})

krun = KRun(definition_dir=Path(kompiled))

# # state = llvm_interpret(pattern=init_pattern, definition_dir=kompiled, depth=0)
state = krun.run_pattern(pattern=init_pattern, depth=0)

# init = state

state = llvm_interpret(pattern=state, definition_dir=kompiled)
state = krun.run_pattern(pattern=state)
# print(state)

# init = json.loads(init.json)
# init['args'][1]['args'][4] = state.dict['args'][1]['args'][4]
# init2 = Pattern.from_dict(init)

# state = krun.run_pattern(init2)
print(kore_print(state, definition_dir=kompiled, output=PrintOutput.PRETTY))
