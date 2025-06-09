module{
    hw.module private @AddOne(in %io_a : i8, out res2 : i8) {
        %c1_i8 = hw.constant 1 : i8
        %0 = comb.add %io_a, %c1_i8 {sv.namehint = "_out_T"} : i8
        hw.output %0 : i8
    }
    hw.module @Foo(in %clock: !seq.clock, in %a: i8, in %b: i8, out res: i8 ) {
        %0 = hw.constant 0: i1
        %enable = hw.constant 1: i1
        %addr = hw.constant 1: i2
        %mode = hw.constant 1: i1
        %1 = comb.add %a, %b: i8
        %2 = comb.and %a, %b: i8
        %3 = comb.concat %a, %b: i8, i8
        %4 = comb.divs %a, %b: i8
        %5 = comb.extract %a from 3 : (i8) -> i4
        %6 = comb.icmp bin eq %a, %b : i8
        %7 = comb.mux %0, %a, %b: i8
        %8 = comb.parity %a : i8
        %9 = comb.replicate %a : (i8) -> i16
        %10 = hw.aggregate_constant [-1 : i8, 0 : i8, 1 : i8, 2 : i8] : !hw.array<4xi8>
        %arr1 = hw.array_create %a: i8
        %arr2 = hw.array_create %b: i8
        %arr = hw.array_concat %arr1, %arr2 : !hw.array<1xi8>, !hw.array<1xi8>
        %aa = hw.array_get %arr [%0] : !hw.array<2xi8>, i1
        %11 = hw.instance "i0" @AddOne(io_a: %a: i8) -> (res2: i8)
        %12 = seq.from_clock %clock

        %a_first_counter = seq.firreg %2 clock %clock reset sync %0, %4 {firrtl.random_init_start = 0 : ui64} : i8
        
        %ram = seq.firmem 0, 1, undefined, port_order {prefix = ""} : <4 x 8>
        seq.firmem.write_port %ram[%addr] = %7, clock %clock enable %enable : <4 x 8>
        seq.firmem.write_port %ram[%addr] = %2, clock %clock enable %enable : <4 x 8>
        %14 = seq.firmem.read_port %ram[%addr], clock %clock : <4 x 8>
        %15 = seq.firmem.read_write_port %ram[%addr] = %1 if %mode, clock %clock enable %enable {sv.namehint = "data11111"} : <4 x 8>
        sv.always posedge  %12 {
            sv.if %enable {
                sv.info "hitIf"
            }
        }
        hw.output %15 : i8
    }
}
