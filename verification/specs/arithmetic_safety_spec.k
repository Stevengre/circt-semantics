requires "../src/mlir/mlir.k"

module ARITHMETIC-SAFETY-SYNTAX
    syntax BareId ::= "value" [token]
                    | "a" [token]
                    | "b" [token]  
                    | "sum" [token]
                    | "overflow" [token]
                    | "a_ext" [token]
                    | "b_ext" [token]
                    | "sum_ext" [token]
                    | "c0_i1" [token]
                    | "c16_i5" [token]
                    | "overflow_alt" [token]
                    | "parameters" [token]
                    | "module_type" [token]
                    | "lowBit" [token]
                    | "predicate" [token]
    
    syntax AttributeAlias ::= "#loc" [token]
                            | "#loc1" [token] 
                            | "#loc2" [token]
                            | "#loc3" [token]
                            | "#loc4" [token]
                            | "#loc5" [token]
endmodule

module ARITHMETIC-SAFETY-VERIFICATION
    imports K-EQUAL
    imports ARITHMETIC-SAFETY-SYNTAX
    imports MAIN

    // Overflow condition: sum >= 16 for 4-bit arithmetic
    rule { A:Int +Int B:Int >=Int 16 #Equals true } => { (A +Int B) >=Int 16 ==Bool true } [simplification]
    rule { A:Int +Int B:Int <Int 16 #Equals false } => { (A +Int B) <Int 16 ==Bool false } [simplification]
    
    // 4-bit unsigned range: 0 <= value <= 15
    syntax Bool ::= isValid4Bit(Int) [function]
    rule isValid4Bit(X:Int) => X >=Int 0 andBool X <=Int 15
    
    // Overflow detection for 4-bit addition
    syntax Bool ::= hasOverflow4Bit(Int, Int) [function]
    rule hasOverflow4Bit(A:Int, B:Int) => (A +Int B) >=Int 16
endmodule

module ARITHMETIC-SAFETY-SPEC
    imports ARITHMETIC-SAFETY-VERIFICATION

    // Claim for 4-bit adder overflow detection
    claim
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "Adder4BitOverflow" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "Adder4BitOverflow" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %c0_i1 |-> "hw.constant" ( .ValueIdList ) { value = 0 : i1 } : ( .Types ) -> ( i1 , .Types )
                    %c16_i5 |-> "hw.constant" ( .ValueIdList ) { value = 16 : i5 } : ( .Types ) -> ( i5 , .Types )
                    %a_ext |-> "comb.concat" ( %c0_i1 , %a , .ValueIdList ) : ( i1 , i4 , .Types ) -> ( i5 , .Types )
                    %b_ext |-> "comb.concat" ( %c0_i1 , %b , .ValueIdList ) : ( i1 , i4 , .Types ) -> ( i5 , .Types )
                    %sum_ext |-> "comb.add" ( %a_ext , %b_ext , .ValueIdList ) : ( i5 , i5 , .Types ) -> ( i5 , .Types )
                    %sum |-> "comb.extract" ( %sum_ext , .ValueIdList ) { lowBit = 0 } : ( i5 , .Types ) -> ( i4 , .Types )
                    %overflow |-> "comb.extract" ( %sum_ext , .ValueIdList ) { lowBit = 4 } : ( i5 , .Types ) -> ( i1 , .Types )
                    %overflow_alt |-> "comb.icmp" ( %sum_ext , %c16_i5 , .ValueIdList ) { predicate = 2 } : ( i5 , i5 , .Types ) -> ( i1 , .Types )
                </locals>
                <module> "Adder4BitOverflow" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?Sum , 4 ) : i4 ) ListItem ( bits ( ?Overflow , 1 ) : i1 ) </out-ports>
                <out-vars> %sum , %overflow , .ValueIdList </out-vars>
                <args>
                    ListItem ( bits ( A:Int , 4 ) : i4 )
                    ListItem ( bits ( B:Int , 4 ) : i4 )
                </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        requires isValid4Bit(A) andBool isValid4Bit(B)
        ensures (?Overflow ==Int 1) ==Bool ((A +Int B) >=Int 16)

    // Claim for no overflow case: when sum < 16, overflow should be false
    claim
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "Adder4BitOverflow" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "Adder4BitOverflow" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %c0_i1 |-> "hw.constant" ( .ValueIdList ) { value = 0 : i1 } : ( .Types ) -> ( i1 , .Types )
                    %c16_i5 |-> "hw.constant" ( .ValueIdList ) { value = 16 : i5 } : ( .Types ) -> ( i5 , .Types )
                    %a_ext |-> "comb.concat" ( %c0_i1 , %a , .ValueIdList ) : ( i1 , i4 , .Types ) -> ( i5 , .Types )
                    %b_ext |-> "comb.concat" ( %c0_i1 , %b , .ValueIdList ) : ( i1 , i4 , .Types ) -> ( i5 , .Types )
                    %sum_ext |-> "comb.add" ( %a_ext , %b_ext , .ValueIdList ) : ( i5 , i5 , .Types ) -> ( i5 , .Types )
                    %sum |-> "comb.extract" ( %sum_ext , .ValueIdList ) { lowBit = 0 } : ( i5 , .Types ) -> ( i4 , .Types )
                    %overflow |-> "comb.extract" ( %sum_ext , .ValueIdList ) { lowBit = 4 } : ( i5 , .Types ) -> ( i1 , .Types )
                </locals>
                <module> "Adder4BitOverflow" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?Sum , 4 ) : i4 ) ListItem ( bits ( ?Overflow , 1 ) : i1 ) </out-ports>
                <out-vars> %sum , %overflow , .ValueIdList </out-vars>
                <args>
                    ListItem ( bits ( A:Int , 4 ) : i4 )
                    ListItem ( bits ( B:Int , 4 ) : i4 )
                </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        requires isValid4Bit(A) andBool isValid4Bit(B) andBool (A +Int B) <Int 16
        ensures ?Overflow ==Int 0 andBool ?Sum ==Int (A +Int B)

    // Claim for overflow case: when sum >= 16, overflow should be true
    claim
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "Adder4BitOverflow" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "Adder4BitOverflow" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %c0_i1 |-> "hw.constant" ( .ValueIdList ) { value = 0 : i1 } : ( .Types ) -> ( i1 , .Types )
                    %c16_i5 |-> "hw.constant" ( .ValueIdList ) { value = 16 : i5 } : ( .Types ) -> ( i5 , .Types )
                    %a_ext |-> "comb.concat" ( %c0_i1 , %a , .ValueIdList ) : ( i1 , i4 , .Types ) -> ( i5 , .Types )
                    %b_ext |-> "comb.concat" ( %c0_i1 , %b , .ValueIdList ) : ( i1 , i4 , .Types ) -> ( i5 , .Types )
                    %sum_ext |-> "comb.add" ( %a_ext , %b_ext , .ValueIdList ) : ( i5 , i5 , .Types ) -> ( i5 , .Types )
                    %sum |-> "comb.extract" ( %sum_ext , .ValueIdList ) { lowBit = 0 } : ( i5 , .Types ) -> ( i4 , .Types )
                    %overflow |-> "comb.extract" ( %sum_ext , .ValueIdList ) { lowBit = 4 } : ( i5 , .Types ) -> ( i1 , .Types )
                </locals>
                <module> "Adder4BitOverflow" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?Sum , 4 ) : i4 ) ListItem ( bits ( ?Overflow , 1 ) : i1 ) </out-ports>
                <out-vars> %sum , %overflow , .ValueIdList </out-vars>
                <args>
                    ListItem ( bits ( A:Int , 4 ) : i4 )
                    ListItem ( bits ( B:Int , 4 ) : i4 )
                </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        requires isValid4Bit(A) andBool isValid4Bit(B) andBool (A +Int B) >=Int 16
        ensures ?Overflow ==Int 1 andBool ?Sum ==Int ((A +Int B) &Int 15)
endmodule