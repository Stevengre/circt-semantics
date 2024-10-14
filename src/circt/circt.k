requires "./common.k"
requires "./conf.k"
requires "../dialects/hw/hw-inout.k"

module CIRCT-SYNTAX-CORE
    imports MLIR
    imports COMMON-SYNTAX
endmodule


module CIRCT-CONF
    imports CONF
endmodule


module CIRCT-SYNTAX
    imports CIRCT-CONF

    syntax Set ::= toSet(ValueIdList) [function]
    rule toSet(V:ValueId, VL:ValueIdList) => SetItem(V) toSet(VL)
    rule toSet(.ValueIdList) => .Set

    syntax List ::= toList(AttributeValueList) [function]
    rule toList(V:AttributeValue, VL:AttributeValueList) => ListItem(V) toList(VL)
    rule toList(.AttributeValueList) => .List

    syntax List ::= toList(ValueIdList) [function]
    rule toList(V:ValueId, VL:ValueIdList) => ListItem(V) toList(VL)
    rule toList(.ValueIdList) => .List
endmodule


module CIRCT
    imports COMMON
    imports CIRCT-SYNTAX
endmodule