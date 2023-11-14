// RUN: not krun -d %kdir %s 2>&1 | FileCheck %s

// CHECK: [Error] Inner Parser: Parse error: unexpected token '0xf32' following token
// Zero-element tensor of f32 type (hexadecimal literals not allowed here).
tensor<0xf32>
