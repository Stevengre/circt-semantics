# Readme


dependency relation
```yaml
main-syntax
    circt-syntax
    - common
        - mlir-syntax
        - bits
        - stdvalue
    - builtin
        - circt-syntax-core
    - dialects
        - comb
        - sv
        - hw
        - seq

circt-syntax
- bits
- s