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

    rule <k> "hw.output" ( Vs:ValueIdList ) : ( _:Types ) -> ( .Types ) => .K ... </k>
        <out-vars> _ => Vs </out-vars>
        <cmd> #bootstrap ... </cmd>

    rule <k>
            "hw.module" ( .ValueIdList ) ( R:Region ) { Attr:Map } : ( .Types ) -> ( .Types )
            => R
            ...
        </k>
        <in-names> _ => getModuleInNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </in-names>
        <out-names> _ => getModuleOutNames({Attr["module_type"] orDefault !hw.modty < .ModulePortList >}:>HwModty) </out-names>
        <cmd> #bootstrap ... </cmd>
endmodule