OCAMLBUILD = ocamlbuild -use-ocamlfind -plugin-tag "package(ocamlbuild_atdgen)"

build:
	$(OCAMLBUILD) src/reminder.native

clean:
	$(OCAMLBUILD) -clean

.PHONY: clean
.PHONY: build
