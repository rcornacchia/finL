open Printf
open String

type action = Ast | Sast | Compile

let _ =
	let action =
		if Array.length Sys.argv = 3 then
      List.assoc Sys.argv.(1) [ ("-a", Ast); ("-s", Sast); ("-c", Compile)]
    else Compile in
    let file_index = (Array.length Sys.argv) - 1 in
      let read_file = open_in Sys.argv.(file_index) in
      let lexbuf = Lexing.from_channel read_file in
      let program = Parser.program Scanner.token lexbuf in
      match action with
        Ast -> print_string (Ast.string_of_program program)
        | _ ->
          let checked_program = Semantics.analyze program in
          (match action with
            Sast -> print_string (Sast.string_of_sprogram checked_program)
            | _ ->
              let last_slash = try rindex Sys.argv.(1) '/' with Not_found -> -1 in
              let start = last_slash + 1 in
              let name = sub Sys.argv.(file_index) start ((length Sys.argv.(file_index)) - 5 - start) in     
              let write_file = open_out (name ^ ".java") in
              let compiled_program = Compile.compile checked_program name in
                (*fprintf write_file "%s" compiled_program;*)
                close_out write_file; 
                (*ignore (Sys.command ("javac " ^ name ^ ".java"))*))
		(*else (*Compile in*) print_endline "Please specify exactly 1 filename."*)