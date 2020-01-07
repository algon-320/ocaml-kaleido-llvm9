OPTS := -use-ocamlfind -lflags -cclib,-lbindings,-ccopt,-L./

toy.native: *.ml _build/libbindings.so _tags
	ocamlbuild $(OPTS) toy.native

_build/libbindings.so: bindings.c
	mkdir -p _build
	gcc -shared bindings.c -o _build/libbindings.so

.PHONY: debug
debug:
	ocamlbuild $(OPTS) -tag debug toy.native

.PHONY: run
run: toy.native
	cat prelude.txt mandelbrot.txt - | LD_LIBRARY_PATH=_build ./toy.native

.PHONY: clean
clean:
	-rm -r _build toy.native
