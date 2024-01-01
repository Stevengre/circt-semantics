FIRRTL version 2.0.0
circuit AddTwo :
  module AddOne :
    input clock : Clock
    input reset : Reset
    input in : UInt<8> @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 13:23]
    output out : UInt<8> @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 14:23]

    node _out_T = add(in, UInt<1>("h1")) @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 15:13]
    node _out_T_1 = tail(_out_T, 1) @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 15:13]
    out <= _out_T_1 @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 15:7]

  module AddTwo :
    input clock : Clock
    input reset : UInt<1>
    input in : UInt<8> @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 19:15]
    output out : UInt<8> @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 20:15]

    inst i0 of AddOne @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 22:20]
    i0.clock <= clock @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 22:20]
    i0.reset <= reset @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 22:20]
    inst i1 of AddOne @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 23:20]
    i1.clock <= clock @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 23:20]
    i1.reset <= reset @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 23:20]
    i0.in <= in @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 24:9]
    i1.in <= i0.out @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 25:9]
    out <= i1.out @[Users/steven/Desktop/Projects/circt-semantics/kirct/tests/resource/circt_modules/chisel-lang-docs/cookbook-hierarchy/source/AddTwo.scala 26:9]


