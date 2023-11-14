// : kparse %s -d %kdir
#map = affine_map<(d0) -> (d0 + 10)>

// Using the original attribute.
%b = affine.apply affine_map<(d0) -> (d0 + 10)> (%a)

// Using the attribute alias.
%b = affine.apply #map(%a)