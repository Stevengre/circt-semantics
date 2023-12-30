1. before 2023.12.15: using this commit https://github.com/llvm/circt/commit/390709ff4e409b27cf0b0a23cd70093bb008fa34
2. 2023.12.15 using: https://github.com/llvm/circt/commit/57372957e8365b34ca469299b8c864d830e836a1
2. 2023.12.15 found: new type without its syntax and explanation in https://circt.llvm.org/docs/Dialects/HW/#moduletype
   1. !hw.modty<input arge : i3, input arg1 : i1, input arg2 : !hw.array<16e8xi8>, output result 150>
2. 2023.12.15 found: the dialect type contents can be anything, so it should be in the dialect syntax rather than the mlir syntax.
```bnf
dialect-type-body ::= `<` dialect-type-contents+ `>`
dialect-type-contents ::= dialect-type-body
                            | `(` dialect-type-contents+ `)`
                            | `[` dialect-type-contents+ `]`
                            | `{` dialect-type-contents+ `}`
                            | [^\[<({\]>)}\0]+
```
3. 2023.12.21 found: why the previous nested adder is wrong -> 1. not in the module to build symbol table 2. the submodule is not private.
4. 2023.12.21 found: a new dialect is required without its role described in https://circt.llvm.org