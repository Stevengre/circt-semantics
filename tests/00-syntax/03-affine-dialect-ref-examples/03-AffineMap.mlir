// : krun -d %kdir %s
// Affine map out-of-line definition and usage example.
#affine_map42 = affine_map<(d0, d1)[s0] -> (d0, d0 + d1 + s0 floordiv 2)>

// Use an affine mapping definition in an alloc operation, binding the
// SSA value %N to the symbol s0.
%a = memref.alloc()[%N] : memref<4x4xf32, #affine_map42>

// Same thing with an inline affine mapping definition.
%b = memref.alloc()[%N] : memref<4x4xf32, affine_map<(d0, d1)[s0] -> (d0, d0 + d1 + s0 floordiv 2)>>