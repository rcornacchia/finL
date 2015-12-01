open Ast
(*open Sast*)

exception Except of string

let check_for_main fdecls =
	let found = List.exists (fun f -> f.name = "main") fdecls in
	if found then fdecls
	else raise (Except("No main function found!"))

let analyze (prog: Ast.program) =
	let fdecls = check_for_main prog.fdecls in
	prog