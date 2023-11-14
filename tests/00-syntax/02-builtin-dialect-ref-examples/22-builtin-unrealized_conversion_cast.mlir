// RUN: krun -d %kdir %s
// An unrealized 0-1 conversion. These types of conversions are useful in
// cases where a type is removed from the type system, but not all uses have
// been converted. For example, imagine we have a tuple type that is
// expanded to its element types. If only some uses of an empty tuple type
// instance are converted we still need an instance of the tuple type, but
// have no inputs to the unrealized conversion.
%result = unrealized_conversion_cast to !bar.tuple_type<>

// An unrealized 1-1 conversion.
%result1 = unrealized_conversion_cast %operand : !foo.type to !bar.lowered_type

// An unrealized 1-N conversion.
%results2:2 = unrealized_conversion_cast %tuple_operand : !foo.tuple_type<!foo.type, !foo.type> to !foo.type, !foo.type

// An unrealized N-1 conversion.
%result3 = unrealized_conversion_cast %operand, %operand : !foo.type, !foo.type to !bar.tuple_type<!foo.type, !foo.type>