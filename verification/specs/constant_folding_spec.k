requires "../src/mlir/mlir.k"

module CONSTANT-FOLDING-SYNTAX
    syntax BareId ::= "value" [token]
                    | "result" [token]
                    | "parameters" [token]
                    | "c5" [token]
                    | "c3" [token]
                    | "c8" [token]
                    | "sum" [token]
                    | "module_type" [token]
    
    syntax AttributeAlias ::= "#loc" [token]
                            | "#loc1" [token]
                            | "#loc2" [token]
                            | "#loc3" [token]
endmodule

module CONSTANT-FOLDING-VERIFICATION
    imports K-EQUAL
    imports CONSTANT-FOLDING-SYNTAX
    imports MAIN

    // Simplification rule for constant folding verification
    rule { A:Int |Int B:Int #Equals C:Int } => {A +Int B #Equals C} [simplification]
endmodule

module CONSTANT-FOLDING-SPEC
    imports CONSTANT-FOLDING-VERIFICATION

    // Claim for constant folding equivalence verification
    claim
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "ConstantFoldingOriginal" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "ConstantFoldingOriginal" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %c5 |-> "hw.constant" ( .ValueIdList ) { value = 5 : i8 } : ( .Types ) -> ( i8 , .Types )
                    %c3 |-> "hw.constant" ( .ValueIdList ) { value = 3 : i8 } : ( .Types ) -> ( i8 , .Types )
                    %sum |-> "comb.add" ( %c5 , %c3 , .ValueIdList ) : ( i8 , i8 , .Types ) -> ( i8 , .Types )
                </locals>
                <module> "ConstantFoldingOriginal" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?OriginalResult , 8 ) : i8 ) </out-ports>
                <out-vars> %sum , .ValueIdList </out-vars>
                <args> .List </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        ensures ?OriginalResult ==Int 8

    // Claim for optimized constant folding verification  
    claim
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "ConstantFoldingOptimized" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "ConstantFoldingOptimized" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %c8 |-> "hw.constant" ( .ValueIdList ) { value = 8 : i8 } : ( .Types ) -> ( i8 , .Types )
                </locals>
                <module> "ConstantFoldingOptimized" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?OptimizedResult , 8 ) : i8 ) </out-ports>
                <out-vars> %c8 , .ValueIdList </out-vars>
                <args> .List </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        ensures ?OptimizedResult ==Int 8
        
    // Equivalence claim: both versions should produce the same output
    claim
        <mlir>
            <prog> .K </prog>
            <phase> #build </phase>
            <types> .Map </types>
            <attrs> .Map </attrs>
            <table> .Map </table>
        </mlir>
        <cmd> #always => #end </cmd>
        <entry> "ConstantFoldingOriginal" </entry>
        <input> .List </input>
        <clock> 0 </clock>
        <running> .List </running>
        <boot> .List </boot>
        <ckts>
            <ckt>
                <cid> "ConstantFoldingOriginal" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %c5 |-> "hw.constant" ( .ValueIdList ) { value = 5 : i8 } : ( .Types ) -> ( i8 , .Types )
                    %c3 |-> "hw.constant" ( .ValueIdList ) { value = 3 : i8 } : ( .Types ) -> ( i8 , .Types )
                    %sum |-> "comb.add" ( %c5 , %c3 , .ValueIdList ) : ( i8 , i8 , .Types ) -> ( i8 , .Types )
                </locals>
                <module> "ConstantFoldingOriginal" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?R1 , 8 ) : i8 ) </out-ports>
                <out-vars> %sum , .ValueIdList </out-vars>
                <args> .List </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
            <ckt>
                <cid> "ConstantFoldingOptimized" </cid>
                <always> .List </always>
                <initial> .List </initial>
                <k> #HwOutput => .K </k>
                <parent> "" </parent>
                <last> .Map </last>
                <locals>
                    %c8 |-> "hw.constant" ( .ValueIdList ) { value = 8 : i8 } : ( .Types ) -> ( i8 , .Types )
                </locals>
                <module> "ConstantFoldingOptimized" </module>
                <in-ports> .List </in-ports>
                <in-vars> .ValueIdAndTypeList </in-vars>
                <out-ports> _ => ListItem ( bits ( ?R2 , 8 ) : i8 ) </out-ports>
                <out-vars> %c8 , .ValueIdList </out-vars>
                <args> .List </args>
                <regs> .Map </regs>
                <wires> .Map </wires>
            </ckt>
        </ckts>
        ensures ?R1 ==Int ?R2
endmodule