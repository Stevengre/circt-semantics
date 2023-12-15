module {
    hw.module @Swap(in %x: i8, in %y: i8, out result1: i8, out result2: i8) {
        hw.output %y, %x : i8, i8
    }

    hw.module @Adder(in %a: i8, in %b: i8, out result: i8 ) {
        %x, %y = hw.instance "swap" @Swap("x" : %a: i8, "y": %b : i8) -> ("result1": i8, "result2": i8)
        %out = comb.add %x, %y : i8
        hw.output %out : i8
    }
}