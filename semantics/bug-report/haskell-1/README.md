In argument sorts: Sort 'SortIntegerType' does not have domain values.

Ah, I see the problem here <@1009071320283230299> - to use the `token2string` hook you need the argument sort to directly be a token sort. You would need to define a token2string hook for _each_ of your `*IntegerType` sorts, then a rule for `IntegerType` that dispatches to each of them