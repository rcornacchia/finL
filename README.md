# finL

## Package Manager and IDE

http://opam.ocaml.org/doc/Install.html

http://www.typerex.org/ocaml-top.html

# Compiling finL Compiler
	$ make

# Compiling and Running a Single Program
	$ ./finlc [filename.finl]
	$ ./finl.sh [filename]

# Options
	$ ./finlc -a [filename.finl] #prints ast
	$ ./finlc -s [filename.finl] #prints sast

# Running Regression Test
	$ ./regression_test.sh