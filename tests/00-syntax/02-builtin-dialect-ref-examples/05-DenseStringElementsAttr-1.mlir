// RUN: krun -d %kdir %s
// A splat tensor of strings.
dense<"example"> : tensor<2x!foo.string>