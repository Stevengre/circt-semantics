// : krun -d %kdir %s
// A example two-dimensional integer set with two symbols.
#set42 = affine_set<(d0, d1)[s0, s1]
   : (d0 >= 0, -d0 + s0 - 1 >= 0, d1 >= 0, -d1 + s1 - 1 >= 0)>

// Inside a Region
affine.if #set42(%i, %j)[%M, %N] {
  // ...
}