.PHONY : make
make :
	ocamllex scanner.mll
	ocamlyacc -v parser.mly
	ocamlc -c ast.mli
	ocamlc -c parser.mli
	ocamlc -c scanner.ml
	ocamlc -c parser.ml
	ocamlc -c interpret.ml


.PHONY : clean
clean :
	rm -f interpret parser.ml parser.mli scanner.ml \
	*.cmo *.cmi *.output
