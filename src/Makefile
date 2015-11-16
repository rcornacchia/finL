.PHONY : make
make :
	ocamlc -c ast.mli
	ocamlyacc -v parser.mly
	ocamlc -c parser.mli
	ocamlc -c parser.ml
	ocamllex scanner.mll
	ocamlc -c scanner.ml
	#ocamlc -c interpret.ml
	ocamlc -c compile.ml
	ocamlc -c finlc.ml
	ocamlc -o finlc ast.cmo parser.cmo scanner.cmo compile.cmo finl.cmo


.PHONY : clean
clean :
	rm -f interpret parser.ml parser.mli scanner.ml \
	*.cmo *.cmi *.output