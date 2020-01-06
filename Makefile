toy.byte: *.ml _tags
	ocamlbuild toy.byte

.PHONY: run
run: toy.byte
	./toy.byte

.PHONY: clean
clean:
	rm -r _build toy.byte
