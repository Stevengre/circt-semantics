hw.module
```mlir
#loc = loc("/tmp/tmp4_6__l0t.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.hierpath
```mlir
#loc = loc("/tmp/tmpuvnr6gdh.mlir":1:42)
#loc1 = loc("/tmp/tmpuvnr6gdh.mlir":6:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "sv.reg"() {inner_sym = #hw<innerSym@sym_reg>, name = "reg", sv.attributes = [#sv.attribute<"dont_merge">]} : () -> !hw.inout<i8>
    %1 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Bar"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.instance"(%arg0, %arg1) {argNames = ["a", "b"], inner_sym = #hw<innerSym@sym_bar>, instanceName = "bar", moduleName = @Bar, parameters = [], resultNames = ["res"]} : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc1], sym_name = "Foo"} : () -> ()
  "hw.hierpath"() {namepath = [#hw.innerNameRef<@Foo::@sym_bar>, #hw.innerNameRef<@Bar::@sym_reg>], sym_name = "ref"} : () -> ()
  "hw.module"() ({
    %0 = "sv.xmr.ref"() {ref = @ref, verbatimSuffix = ""} : () -> !hw.inout<i8>
    "hw.output"() : () -> ()
  }) {module_type = !hw.modty<>, parameters = [], sym_name = "Top"} : () -> ()
}) : () -> ()
```

hw.instance
```mlir
#loc = loc("/tmp/tmppkdqz7ti.mlir":1:42)
#loc1 = loc("/tmp/tmppkdqz7ti.mlir":5:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Bar"} : () -> ()
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.instance"(%arg0, %arg1) {argNames = ["a", "b"], inner_sym = #hw<innerSym@sym_bar>, instanceName = "bar", moduleName = @Bar, parameters = [], resultNames = ["res"]} : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc1], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.output
```mlir
#loc = loc("/tmp/tmp4dz8kd8j.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "comb.add"(%arg0, %arg1) : (i8, i8) -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.triggered
```mlir
"builtin.module"() ({
^bb0:
}) : () -> ()
```

hw.bitcast
```mlir
#loc = loc("/tmp/tmpdn3me0i_.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.struct_create"(%arg0, %arg1) : (i8, i8) -> !hw.struct<a: i8, b: i8>
    %1 = "hw.bitcast"(%0) : (!hw.struct<a: i8, b: i8>) -> i16
    "hw.output"(%1) : (i16) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i16>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.constant
```mlir
#loc = loc("/tmp/tmplnnsh8hb.mlir":1:20)
"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.constant"() {value = 42 : i8} : () -> i8
    "hw.output"(%0) : (i8) -> ()
  }) {module_type = !hw.modty<output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.enum.constant
hw.enum.cmp
```mlir
#loc = loc("/tmp/tmp8w1cakxc.mlir":1:20)
"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.enum.constant"() {field = #hw.enum.field<A, !hw.enum<A, B, C>>} : () -> !hw.enum<A, B, C>
    %1 = "hw.enum.constant"() {field = #hw.enum.field<A, !hw.enum<A, B, C>>} : () -> !hw.enum<A, B, C>
    %2 = "hw.enum.cmp"(%0, %1) : (!hw.enum<A, B, C>, !hw.enum<A, B, C>) -> i1
    "hw.output"(%2) : (i1) -> ()
  }) {module_type = !hw.modty<output res : i1>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.param.value
```mlir
"builtin.module"() ({
^bb0:
}) : () -> ()
```

hw.wire
```mlir
#loc = loc("/tmp/tmpsycymo9r.mlir":1:20)
"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.constant"() {value = 0 : i8} : () -> i8
    %1 = "hw.wire"(%0) {inner_sym = #hw<innerSym@mySym>, name = "myWire"} : (i8) -> i8
    "hw.output"(%1) : (i8) -> ()
  }) {module_type = !hw.modty<output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.aggregate_constant
```mlir
#loc = loc("/tmp/tmpd8l6f_80.mlir":1:20)
"builtin.module"() ({
  "hw.module"() ({
    %0 = "hw.aggregate_constant"() {fields = [true, -2 : i2, -1 : i2]} : () -> !hw.struct<a: i1, b: i2, c: i2>
    "hw.output"(%0) : (!hw.struct<a: i1, b: i2, c: i2>) -> ()
  }) {module_type = !hw.modty<output res : !hw.struct<a: i1, b: i2, c: i2>>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.array_create
hw.array_get
```mlir
#loc = loc("/tmp/tmp9d6ve9ti.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.array_create"(%arg0, %arg1) : (i8, i8) -> !hw.array<2xi8>
    %1 = "hw.constant"() {value = false} : () -> i1
    %2 = "hw.constant"() {value = true} : () -> i1
    %3 = "hw.array_get"(%0, %1) : (!hw.array<2xi8>, i1) -> i8
    %4 = "hw.array_get"(%0, %2) : (!hw.array<2xi8>, i1) -> i8
    %5 = "comb.add"(%3, %4) : (i8, i8) -> i8
    "hw.output"(%5) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.array_concat
```mlir
#loc = loc("/tmp/tmpf53fgqow.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.array_create"(%arg0) : (i8) -> !hw.array<1xi8>
    %1 = "hw.array_create"(%arg1) : (i8) -> !hw.array<1xi8>
    %2 = "hw.array_concat"(%0, %1) : (!hw.array<1xi8>, !hw.array<1xi8>) -> !hw.array<2xi8>
    %3 = "hw.constant"() {value = false} : () -> i1
    %4 = "hw.constant"() {value = true} : () -> i1
    %5 = "hw.array_get"(%2, %3) : (!hw.array<2xi8>, i1) -> i8
    %6 = "hw.array_get"(%2, %4) : (!hw.array<2xi8>, i1) -> i8
    %7 = "comb.add"(%5, %6) : (i8, i8) -> i8
    "hw.output"(%7) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.array_slice
```mlir
#loc = loc("/tmp/tmpj81b3_gw.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.array_create"(%arg0, %arg1, %arg0, %arg1) : (i8, i8, i8, i8) -> !hw.array<4xi8>
    %1 = "hw.constant"() {value = -2 : i2} : () -> i2
    %2 = "hw.array_slice"(%0, %1) : (!hw.array<4xi8>, i2) -> !hw.array<2xi8>
    %3 = "hw.constant"() {value = false} : () -> i1
    %4 = "hw.constant"() {value = true} : () -> i1
    %5 = "hw.array_get"(%2, %3) : (!hw.array<2xi8>, i1) -> i8
    %6 = "hw.array_get"(%2, %4) : (!hw.array<2xi8>, i1) -> i8
    %7 = "comb.add"(%5, %6) : (i8, i8) -> i8
    "hw.output"(%7) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.struct_create
hw.struct_extract
```mlir
#loc = loc("/tmp/tmp21d81bqv.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.struct_create"(%arg0, %arg1) : (i8, i8) -> !hw.struct<a: i8, b: i8>
    %1 = "hw.struct_extract"(%0) {fieldIndex = 0 : i32} : (!hw.struct<a: i8, b: i8>) -> i8
    %2 = "hw.struct_extract"(%0) {fieldIndex = 1 : i32} : (!hw.struct<a: i8, b: i8>) -> i8
    %3 = "comb.add"(%1, %2) : (i8, i8) -> i8
    "hw.output"(%3) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.struct_explode
```mlir
#loc = loc("/tmp/tmp08n6jvee.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.struct_create"(%arg0, %arg1) : (i8, i8) -> !hw.struct<a: i8, b: i8>
    %1:2 = "hw.struct_explode"(%0) : (!hw.struct<a: i8, b: i8>) -> (i8, i8)
    %2 = "comb.add"(%1#0, %1#1) : (i8, i8) -> i8
    "hw.output"(%2) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.struct_inject
```mlir
#loc = loc("/tmp/tmpvwj9a5vo.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.struct_create"(%arg1, %arg0) : (i8, i8) -> !hw.struct<a: i8, b: i8>
    %1 = "hw.struct_inject"(%0, %arg0) {fieldIndex = 0 : i32} : (!hw.struct<a: i8, b: i8>, i8) -> !hw.struct<a: i8, b: i8>
    %2 = "hw.struct_inject"(%1, %arg1) {fieldIndex = 1 : i32} : (!hw.struct<a: i8, b: i8>, i8) -> !hw.struct<a: i8, b: i8>
    %3:2 = "hw.struct_explode"(%2) : (!hw.struct<a: i8, b: i8>) -> (i8, i8)
    %4 = "comb.add"(%3#0, %3#1) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```

hw.union_create
hw.union_extract
```mlir
#loc = loc("/tmp/tmpvf5lh8ss.mlir":1:42)
"builtin.module"() ({
  "hw.module"() ({
  ^bb0(%arg0: i8, %arg1: i8):
    %0 = "hw.union_create"(%arg0) {fieldIndex = 0 : i32} : (i8) -> !hw.union<foo: i8, bar: i8>
    %1 = "hw.union_extract"(%0) {fieldIndex = 0 : i32} : (!hw.union<foo: i8, bar: i8>) -> i8
    %2 = "hw.union_create"(%arg1) {fieldIndex = 1 : i32} : (i8) -> !hw.union<foo: i8, bar: i8>
    %3 = "hw.union_extract"(%2) {fieldIndex = 1 : i32} : (!hw.union<foo: i8, bar: i8>) -> i8
    %4 = "comb.add"(%1, %3) : (i8, i8) -> i8
    "hw.output"(%4) : (i8) -> ()
  }) {module_type = !hw.modty<input a : i8, input b : i8, output res : i8>, parameters = [], result_locs = [#loc], sym_name = "Foo"} : () -> ()
}) : () -> ()
```
