// RUN: not krun -d %kdir %s 2>&1 | FileCheck %s

42 : f32     // Error: expected integer type
// CHECK: {{.*}}error: unexpected token
