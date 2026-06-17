#loc = loc("adder_4bit_overflow.mlir":1:1)
#loc1 = loc("adder_4bit_overflow.mlir":2:1)
#loc2 = loc("adder_4bit_overflow.mlir":3:1)
#loc3 = loc("adder_4bit_overflow.mlir":4:1)
#loc4 = loc("adder_4bit_overflow.mlir":5:1)
#loc5 = loc("adder_4bit_overflow.mlir":6:1)
"builtin.module"() ({
    "hw.module"() ({
    ^bb0(%a: i4, %b: i4):
        // Extend inputs to 5 bits for overflow detection
        %a_ext = "comb.concat"(%c0_i1, %a) : (i1, i4) -> i5
        %b_ext = "comb.concat"(%c0_i1, %b) : (i1, i4) -> i5
        %c0_i1 = "hw.constant"() {value = 0 : i1} : () -> i1
        
        // Perform 5-bit addition
        %sum_ext = "comb.add"(%a_ext, %b_ext) : (i5, i5) -> i5
        
        // Extract 4-bit sum result
        %sum = "comb.extract"(%sum_ext) {lowBit = 0} : (i5) -> i4
        
        // Extract overflow bit (bit 4)
        %overflow = "comb.extract"(%sum_ext) {lowBit = 4} : (i5) -> i1
        
        // Alternative overflow calculation: check if sum >= 16
        %c16_i5 = "hw.constant"() {value = 16 : i5} : () -> i5
        %overflow_alt = "comb.icmp"(%sum_ext, %c16_i5) {predicate = 2} : (i5, i5) -> i1
        
        "hw.output"(%sum, %overflow) : (i4, i1) -> ()
    }) {module_type = !hw.modty<input a : i4, input b : i4, output sum : i4, output overflow : i1>, parameters = [], result_locs = [#loc1, #loc2], sym_name = "Adder4BitOverflow"} : () -> ()
}) : () -> ()