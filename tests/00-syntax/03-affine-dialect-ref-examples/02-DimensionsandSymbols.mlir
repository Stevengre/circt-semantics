// : krun -d %kdir %s
#affine_map2to3 = affine_map<(d0, d1)[s0] -> (d0, d1 + s0, d1 - s0)>
// Binds %N to the s0 symbol in affine_map2to3.
%x = memref.alloc()[%N] : memref<40x50xf32, #affine_map2to3>