// RUN: krun -d %kdir %s
// A tensor referencing a builtin dialect resource, `resource_1`, with two
// unsigned i32 elements.
dense_resource<resource_1> : tensor<2xui32>