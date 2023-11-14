// RUN: krun -d %kdir %s

// Tensor with an encoding attribute (where #ENCODING is a named alias).
tensor<?x?xf64, #ENCODING>