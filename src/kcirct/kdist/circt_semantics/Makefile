# setup these options before running kompile
# K_OPTS+=-Xmx200g
# K_OPTS+=-Xms100g
# K_OPTS+=-Xss1g
# use after changing the syntax
build-bison:
	kompile main.k --gen-bison-parser --bison-stack-max-depth 1000000000
	krun rocket-small-master.generic.mlir --depth 0 > rocket-small-master.kore

# use after changing the semantics with unchanged syntax
build:
	kompile main.k


DEPTH_OPTION=$(if $(DEPTH),--depth $(DEPTH))

run-rocket:
	krun --term --parser 'cat' rocket-small-master.kore $(DEPTH_OPTION) > rocket-small-master$(if $(DEPTH),.$(DEPTH)).out

run-rocket-kore:
	krun --term --parser 'cat' rocket-small-master.kore $(DEPTH_OPTION) -o kore > rocket-small-master$(if $(DEPTH),.$(DEPTH)).kore.out

debug-run-rocket:
	@bash debug_binary.sh $(if $(R),$(R)) $(if $(REMAIN_DEBUG),$(REMAIN_DEBUG)) 


build-test-syntax:
	rm -rf test-syntax-kompiled
	kompile test-syntax.k --gen-bison-parser --bison-stack-max-depth 1000000000 -o test-syntax-kompiled/

build-test-preprocess:
	rm -rf test-preprocess-kompiled
	kompile test-preprocess.k --gen-bison-parser --bison-stack-max-depth 1000000000 -o test-preprocess-kompiled/
