# Verification Syntax 

```k
requires "hardware.md"
requires "bits.md"
module VERIFICATION
imports HARDWARE
imports BITS
imports BOOL
imports STRING
imports K-EQUAL
imports INT-SYNTAX
```

```k
syntax CIRCTError ::= assertionError (String) [symbol(CIRCTError::AssertionError)]
                        | "ReachedUnreachable"
                        | svError(String) [symbol(CIRCTError::SVError)]

syntax KItem ::= CIRCTError

syntax KItem ::= #verifyAssert ( /* COND */ KItem, /* MSG */ String ) 

rule <current> #verifyAssert(COND:Bool, _MSG) => .K ... </current>
  requires COND ==Bool true

rule <current> #verifyAssert(COND:Bool, MSG) => assertionError(MSG) ... </current>
     <sv-logs>
       ... .List => ListItem("ASSERT: " +String MSG)
     </sv-logs>
  requires COND ==Bool false

rule <current> #verifyAssert(bits(V:Int, _W:Int), _MSG) => .K ... </current>
  requires V ==Int 1

rule <current> #verifyAssert(bits(V:Int, _W:Int), MSG) => assertionError(MSG) ... </current>
     <sv-logs>
       ... .List => ListItem("ASSERT: " +String MSG)
     </sv-logs>
  requires V ==Int 0
```

```k
endmodule
```
