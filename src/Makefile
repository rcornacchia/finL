.PHONY : make
make :
	ocamlc -c ast.ml
	ocamlc -c sast.ml
	ocamlyacc -v parser.mly
	ocamlc -c parser.mli
	ocamlc -c parser.ml
	ocamllex scanner.mll
	ocamlc -c scanner.ml
	#ocamlc -c interpret.ml
	ocamlc -c compile.ml
	ocamlc -c semantics.ml
	ocamlc -c finlc.ml
	ocamlc -o finlc sast.cmo ast.cmo parser.cmo scanner.cmo compile.cmo semantics.cmo finlc.cmo

.PHONY : clean
clean :
	rm -f finlc parser.ml parser.mli scanner.ml \
	*.cmo *.cmi *.output *.class *.java *.log