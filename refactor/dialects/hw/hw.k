requires "./hw-modty.k"
requires "./hw-array.k"
requires "./hw-struct.k"
requires "./hw-union.k"
requires "./hw-enum.k"

module HW
    imports HW-ARRAY
    imports HW-STRUCT
    imports HW-UNION
    imports HW-ENUM
    imports HW-MODTY

    rule <k> X:ValueId = "hw.constant" ( .ValueIdList ) { Attr:Map } : ( .Types ) -> ( T:Type ) => .K ... </k>
        <locals> Locals:Map => Locals [X <- AV2StdValue({Attr["value"]}:>AttributeValue, T)] </locals>
        <cmd> #bootstrap ... </cmd>
endmodule