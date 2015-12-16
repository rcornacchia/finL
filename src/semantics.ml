open Ast
open Sast

exception Except of string

let builtin_functions = 
	[ { sname = "print";
		sformals = [];
		sbody = []; } ]

let analyze_fdecl (fdecl: Ast.func_decl) =
	{ sname = fdecl.name;
	  sformals = [];
	  sbody = []; }

let check_function funcs (fdecl: Ast.func_decl) =
	let found = List.exists (fun f -> f.sname = fdecl.name) funcs in
	if found then raise (Except(fdecl.name ^ " already exists!"))
	else let sfdecl = analyze_fdecl fdecl (* probably need environment here *) in
	sfdecl :: funcs

let check_for_main fdecls =
	let found = List.exists (fun f -> f.name = "main") fdecls in
	if found then raise (Except("Illegal function name 'main'!")) (* should be allowed to have function named main *)
	else fdecls

let analyze (prog: Ast.program) =
	let fdecls = check_for_main prog.fdecls in
	let function_table = List.fold_left check_function builtin_functions fdecls in
	(*let env = List.fold_left check_function builtin_functions fdecls*)
	{ sfdecls = function_table; sstatements = [] }