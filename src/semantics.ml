open Ast
(*open Sast*)

exception Except of string

(*let builtin_functions = 
	{}*)

let check_for_main fdecls =
	let found = List.exists (fun f -> f.name = "main") fdecls in
	if found then raise (Except("Illegal function name 'main'!")) (* should be allowed to have function named main *)
	else fdecls

let analyze (prog: Ast.program) =
	let fdecls = check_for_main prog.fdecls in
	(*let env = List.fold_left check_function builtin_functions fdecls*)
	prog