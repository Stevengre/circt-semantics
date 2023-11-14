// RUN: krun -d %kdir %s
"any_op"(%a) ({ // if %a is in-scope in the containing region...
    // then %a is in-scope here too.
%new_value = "another_op"(%a) : (i64) -> (i64)
}) : (i64) -> (i64)