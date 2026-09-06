# 打包值的类型布局

MLIR 类型保留元素边界和 operation 的类型约束；运行时整数及一维整数数组
共用 Bits。此模块只计算静态布局，不依赖硬件状态或完整 HW 执行语义。
新增可打包类型时，必须同时核对使用它的 operation 在 CIRCT 中的合法类型。

当前仅支持正位宽整数和正长度的一维整数数组。未支持的类型没有默认位宽，
不能用 0 掩盖类型缺口；嵌套数组、结构体和内存句柄需分别实现并验证。

```k
requires "hw-syntax.md"
requires "../../mlir/builtin.md"

module HW-LAYOUT
  imports HW-SYNTAX
  imports BUILTIN
  imports BOOL

  syntax Bool ::= isPackedType(Type) [function, total]
  rule isPackedType(_:IntegerType) => true
  rule isPackedType(!hw.array < _:SizeX _:IntegerType >) => true
  rule isPackedType(_:Type) => false [owise]

  syntax Int ::= packedWidth(Type) [function]
  rule packedWidth(T:IntegerType) => getWidth(T)
  rule packedWidth(!hw.array < N:SizeX T:IntegerType >)
    => SizeX2Int(N) *Int getWidth(T)

  // 通常要求 ceil(log2(元素数)) 位；CIRCT verifier 对长度 1 也允许 i1。
  // 当前整数词法不支持 i0，长度 1 可以使用 i1 索引 0。
  syntax Int ::= arrayIndexWidth(SizeX) [function]
  rule arrayIndexWidth(N:SizeX) => 0 requires SizeX2Int(N) ==Int 1
  rule arrayIndexWidth(N:SizeX) => log2Int(SizeX2Int(N) -Int 1) +Int 1
    requires SizeX2Int(N) >Int 1

  syntax Bool ::= validArrayIndexWidth(SizeX, Int) [function, total]
  rule validArrayIndexWidth(N:SizeX, W:Int)
    => W ==Int arrayIndexWidth(N) orBool (SizeX2Int(N) ==Int 1 andBool W ==Int 1)
endmodule
```
