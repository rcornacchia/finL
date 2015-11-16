type action = Raw | Compile


let _ =
	let action =
		if Array.length Sys.argv > 1 then
			List.assoc Sys.argv.(1) [ ("-r", Raw);
									  ("-c", Compile)]
		else Compile in
let lexbuf = Lexing.from_channel stdin in
let program = Parser.program Scanner.token lexbuf in
  match action with
  Raw -> print_string (Ast.program_s program)
  | Compile ->
    let compiled_program = Compile.compile program in
    let file = open_out ("finl.java") in
   	fprintf file "%s"  compiled_program; 
