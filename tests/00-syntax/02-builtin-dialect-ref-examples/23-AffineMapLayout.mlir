// RUN: krun -d %kdir %s
// MxN matrix stored in row major layout in memory:
#layout_map_row_major = (i, j) -> (i, j)

// MxN matrix stored in column major layout in memory:
#layout_map_col_major = (i, j) -> (j, i)

// MxN matrix stored in a 2-d blocked/tiled layout with 64x64 tiles.
#layout_tiled = (i, j) -> (i floordiv 64, j floordiv 64, i mod 64, j mod 64)