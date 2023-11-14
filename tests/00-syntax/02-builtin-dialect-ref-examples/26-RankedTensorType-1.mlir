// RUN: krun -d %kdir %s
// Known rank but unknown dimensions.
tensor<? x ? x ? x ? x f32>