# Int Normalization

This module collects local `Int`-level simplifications used by the hardware
semantics. Keep these rules oriented toward smaller terms; do not add
commutativity or associativity rewrites here without a stable ordering strategy.

```k
module INT-NORMALIZATION
    imports INT

    // Arithmetic identities.
    rule X +Int 0 => X [simplification]
    rule 0 +Int X => X [simplification]
    rule X -Int 0 => X [simplification]
    rule X -Int X => 0 [simplification]

    // Bitwise identities.
    rule X xorInt 0 => X [simplification]
    rule 0 xorInt X => X [simplification]
    rule X xorInt X => 0 [simplification]

    rule X |Int 0 => X [simplification]
    rule 0 |Int X => X [simplification]
    rule X |Int X => X [simplification]

    rule X &Int 0 => 0 [simplification]
    rule 0 &Int X => 0 [simplification]
    rule X &Int X => X [simplification]

    // Normalize common bit masks into modular arithmetic.
    rule X &Int (2 ^Int W -Int 1) => X modInt (2 ^Int W) [simplification]
    rule X &Int 255 => X modInt 256 [simplification]
endmodule
```
