// RUN: krun -d %kdir %s
// A 2d to 3d affine mapping.
// d0/d1 are dimensions, s0 is a symbol
#affine_map2to3 = affine_map<(d0, d1)[s0] -> (d0, d1 + s0, d1 - s0)>