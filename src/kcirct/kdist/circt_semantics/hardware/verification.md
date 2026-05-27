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

rule <current> #verifyAssert(true, _MSG) => .K ... </current>
rule <current> #verifyAssert(false, MSG) => assertionError(MSG) ... </current>
<sv-logs> 
   ... .List => ListItem("ASSERT: " +String MSG)
</sv-logs>
rule <current> #verifyAssert(bits(1, _:Int), _MSG) => .K ... </current>
rule <current> #verifyAssert(bits(0, _:Int), MSG) => assertionError(MSG) ... </current>
<sv-logs> 
   ... .List => ListItem("ASSERT: " +String MSG)
</sv-logs>
```

```k
endmodule
```
