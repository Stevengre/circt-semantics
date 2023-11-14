// : krun -d %kdir %s
// A unit attribute defined with the `unit` value specifier.
func.func @verbose_form() attributes {dialectName.unitAttr = unit}

// A unit attribute in an attribute dictionary can also be defined without
// the value specifier.
func.func @simple_form() attributes {dialectName.unitAttr}