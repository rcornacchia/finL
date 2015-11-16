open Printf

type action = Raw | Compile | Interpret

let _ =
	let action =
		if Array.length Sys.argv > 1 then
			List.assoc Sys.argv.(1) [ ("-r", Raw);
									  ("-c", Compile);
									  ("-i", Interpret)]
		else Compile in
let lexbuf = Lexing.from_channel stdin in
let program = Parser.program Scanner.token lexbuf in
  match action with
  Raw -> print_string "to do"
  | Interpret -> print_string "to do"
  | Compile ->
    let compiled_program = Compile.compile program in
    let file = open_out ("finl.java") in
   	fprintf file "%s"  compiled_program; 
