open Printf
open String

(*type action = Raw | Compile | Interpret*)

let _ =
	(*let action =*)
		if Array.length Sys.argv = 2 then begin
      let read_file = open_in Sys.argv.(1) in
      let lexbuf = Lexing.from_channel read_file in
      let program = Parser.program Scanner.token lexbuf in
      (*match action with
        Raw -> print_string "to do"
        | Interpret -> print_string "to do"
        | Compile ->*)
      let last_slash = try rindex Sys.argv.(1) '/' with Not_found -> -1 in
      let start = last_slash + 1 in
      let name = sub Sys.argv.(1) start ((length Sys.argv.(1)) - 5 - start) in     
      let write_file = open_out (name ^ ".java") in
      let compiled_program = Compile.compile program name in
        fprintf write_file "%s" compiled_program;
        close_out write_file; 
        ignore (Sys.command ("javac " ^ name ^ ".java")) end
			(*List.assoc Sys.argv.(1) [ ("-r", Raw);
									              ("-c", Compile);
									              ("-i", Interpret)]*)
		else (*Compile in*) print_endline "Please specify exactly 1 filename."