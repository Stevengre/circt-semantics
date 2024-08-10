requires "./dialects/comb/comb.k"
requires "./circt/circt.k"
requires "./dialects/hw/hw.k"
requires "./dialects/sv/sv.k"

module MAIN
    imports SV
    imports CIRCT
    imports COMB
    imports HW

    // configuration <T>
    //     <circt>
    //         <common/>
    //     </circt>
    // </T>

endmodule