kompile-haskell:
	kompile src/main.k --backend haskell --output-definition main-haskell

kompile-llvm:
	kompile src/main.k --backend llvm --output-definition main-llvm
