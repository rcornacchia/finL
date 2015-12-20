.PHONY : make
make :
	javac -cp ../YahooFinanceAPI-2.0.0.jar bin/*
	ocamlc -c ast.ml
	ocamlc -c sast.ml
	ocamlyacc -v parser.mly
	ocamlc -c parser.mli
	ocamlc -c parser.ml
	ocamllex scanner.mll
	ocamlc -c scanner.ml
	ocamlc -c semantics.ml
	ocamlc -c compile.ml
	ocamlc -c finlc.ml
	ocamlc -o finlc ast.cmo sast.cmo parser.cmo scanner.cmo compile.cmo semantics.cmo finlc.cmo

.PHONY : clean
clean :
	rm -f finlc parser.ml parser.mli scanner.ml bin/*.class \
	*.cmo *.cmi *.output *.class *.java *.log 