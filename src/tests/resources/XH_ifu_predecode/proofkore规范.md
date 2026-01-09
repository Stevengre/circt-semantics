在signal里, 需要创建变量类型
Lbl'Unds'Map'Unds'{}(
  Lbl'UndsPipe'-'-GT-Unds'{}(
    inj{SortString{}, SortKItem{}}(\dv{SortString{}}("Foo/%0")),
    inj{SortBits{}, SortKItem{}}(
      Lblbits'LParUndsCommUndsRParUnds'BITS-SYNTAX'Unds'Bits'Unds'BitsValue'Unds'Int{}(
        inj{SortInt{}, SortBitsValue{}}(VarZ1 : SortInt{}),
        \dv{SortInt{}}("8")
      )
    )
  ),
  Lbl'UndsPipe'-'-GT-Unds'{}(
    inj{SortString{}, SortKItem{}}(\dv{SortString{}}("Foo/%arg1")),
    inj{SortBits{}, SortKItem{}}(
      Lblbits'LParUndsCommUndsRParUnds'BITS-SYNTAX'Unds'Bits'Unds'BitsValue'Unds'Int{}(
        inj{SortInt{}, SortBitsValue{}}(VarY1 : SortInt{}),
        \dv{SortInt{}}("8")
      )
    )
  ),
  VarRest : SortMap{}  // 这里就是“剩下所有内容”的变量
)


Lbl'-LT-'signals'-GT-'{}(\left-assoc{}(Lbl'Unds'Map'Unds'{}(Lbl'UndsPipe'-'-GT-Unds'{}(inj{SortString{}, SortKItem{}}(\dv{SortString{}}("Foo/%0")),inj{SortBits{}, SortKItem{}}(Lblbits'LParUndsCommUndsRParUnds'BITS-SYNTAX'Unds'Bits'Unds'BitsValue'Unds'Int{}(inj{SortInt{}, SortBitsValue{}}(VarZ1 : SortInt{}),\dv{SortInt{}}("8")))),Lbl'UndsPipe'-'-GT-Unds'{}(inj{SortString{}, SortKItem{}}(\dv{SortString{}}("Foo/%arg1")),inj{SortBits{}, SortKItem{}}(Lblbits'LParUndsCommUndsRParUnds'BITS-SYNTAX'Unds'Bits'Unds'BitsValue'Unds'Int{}(inj{SortInt{}, SortBitsValue{}}(VarY1 : SortInt{}),\dv{SortInt{}}("8")))),VarRest:SortMap{})))