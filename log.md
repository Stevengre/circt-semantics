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
5. 2023.12.30 found: this is quite weired for the symbol usage of `i0/io_a`
```mlir
module {
  hw.module private @AddOne(in %io_a : i8, out res : i8) {
    %c1_i8 = hw.constant 1 : i8
    %0 = comb.add %io_a, %c1_i8 {sv.namehint = "_out_T"} : i8
    hw.output %0 : i8
  }
  hw.module private @AddTwo(in %io_a : i8, out res2 : i8) {
    %i0.out = hw.instance "i0" @AddOne(io_a: %io_a: i8) -> (res: i8)
    %i1.out = hw.instance "i1" @AddOne(io_a: %i0.out: i8) -> (res: i8)
    hw.output %i1.out : i8
  }
  hw.module @Adder(in %io_a : i8, out res_out2 : i8, out res_out1: i8) {
    %i3.out = hw.instance "i0" @AddTwo(io_a: %io_a: i8) -> (res2: i8)
    %i4.out = hw.instance "i0" @AddOne(io_a: %i3.out: i8) -> (res: i8)
    hw.output %i3.out, %i4.out : i8, i8
  }
}
```
```json
[
  {
    "name": "Adder",
    "numStateBytes": 14,
    "states": [
      {
        "name": "io_a",
        "offset": 0,
        "numBits": 8,
        "type": "input"
      },
      {
        "name": "res_out2",
        "offset": 1,
        "numBits": 8,
        "type": "output"
      },
      {
        "name": "res_out1",
        "offset": 2,
        "numBits": 8,
        "type": "output"
      },
      {
        "name": "io_a",
        "offset": 3,
        "numBits": 8,
        "type": "wire"
      },
      {
        "name": "i0/io_a",
        "offset": 4,
        "numBits": 8,
        "type": "wire"
      },
      {
        "name": "i0/i0/io_a",
        "offset": 5,
        "numBits": 8,
        "type": "wire"
      },
      {
        "name": "i0/i0/res",
        "offset": 6,
        "numBits": 8,
        "type": "wire"
      },
      {
        "name": "i0/i1/io_a",
        "offset": 7,
        "numBits": 8,
        "type": "wire"
      },
      {
        "name": "i0/i1/res",
        "offset": 8,
        "numBits": 8,
        "type": "wire"
      },
      {
        "name": "i0/res2",
        "offset": 9,
        "numBits": 8,
        "type": "wire"
      },
      {
        "name": "i0/io_a",
        "offset": 10,
        "numBits": 8,
        "type": "wire"
      },
      {
        "name": "i0/res",
        "offset": 11,
        "numBits": 8,
        "type": "wire"
      },
      {
        "name": "res_out2",
        "offset": 12,
        "numBits": 8,
        "type": "wire"
      },
      {
        "name": "res_out1",
        "offset": 13,
        "numBits": 8,
        "type": "wire"
      }
    ]
  }
]
```
甚至这样都是支持的：
```mlir
module {
  hw.module private @AddOne(in %io_a : i8, out res : i8) {
    %c1_i8 = hw.constant 1 : i8
    %0 = comb.add %io_a, %c1_i8 {sv.namehint = "_out_T"} : i8
    hw.output %0 : i8
  }
  hw.module private @AddTwo(in %io_a : i8, out res2 : i8) {
    %i0.out = hw.instance "i0" @AddOne(io_a: %io_a: i8) -> (res: i8)
    %i1.out = hw.instance "i1" @AddOne(io_a: %i0.out: i8) -> (res: i8)
    hw.output %i1.out : i8
  }
  hw.module @Adder(in %io_a : i8, out res_out2 : i8, out res_out1: i8) {
    %i3.out = hw.instance "i0" @AddTwo(io_a: %io_a: i8) -> (res2: i8)
    %i4.out = hw.instance "i0" @AddTwo(io_a: %i3.out: i8) -> (res2: i8)
    hw.output %i3.out, %i4.out : i8, i8
  }
}
```
- 2023.12.30 found: sv.initial and sv.always allow the local vars in them, maybe a undefined behavior? or should be supported as macro?