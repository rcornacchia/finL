# finL

## Package Manager and IDE

http://opam.ocaml.org/doc/Install.html

http://www.typerex.org/ocaml-top.html



#Running a Single File (input.finl)
	$  make clean
	$  make
	$  ./finlc  input.finl
	$  ./finl.sh input

#To Include a Command-Line CSV Portfolio
	$ ./finl.sh input my_portfolio

#Options
	./finlc provides two options: -a and -s

	$  ./finlc -a input.finl 	# prints the abstract syntax tree to the console
	$  ./finlc -s input.finl 	# prints the semantically analyzed syntax tree to the console

#Regression Testing
.$  ./regression_test.sh
