module CTRL
    imports INT
    imports STRING

    syntax Ctrl ::= "mlir"

    syntax Ctrl ::= "preprocess"
                  | "preprocess-" Int

    syntax Ctrl ::= "stop"
                  | "stop" KItem
    
    syntax Ctrl ::= "circt"
                  | "circt" Int
                  
    syntax Ctrl ::= "done"
                  | "done" Int

    syntax Ctrl ::= "initial" | "always"

    syntax Ctrl ::= "do" String
endmodule