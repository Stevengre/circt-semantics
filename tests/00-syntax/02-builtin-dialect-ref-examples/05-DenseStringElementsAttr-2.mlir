// RUN: krun -d %kdir %s
// A tensor of 2 string elements.
dense<["example1", "example2"]> : tensor<2x!foo.string>