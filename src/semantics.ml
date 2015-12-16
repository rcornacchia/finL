open Ast
open Sast

exception Except of string

let builtin_functions = 
	[ { sname = "print";
		sformals = [];
		sbody = []; } ]

let fdecl_to_sfdecl name (fdecl: Ast.func_decl) =
	{ sname = name;
	  sformals = [];
	  sbody = []; }

let check_function funcs (fdecl: Ast.func_decl) =
	let name = 
		if fdecl.name = "main" then "reserved"
		else fdecl.name
	in
	let found = List.exists (fun f -> f.sname = name) funcs in
	if found then raise (Except(fdecl.name ^ " already exists!"))
	else let sfdecl = fdecl_to_sfdecl name fdecl (* probably need environment here *) in
	sfdecl :: funcs

let check_for_builtin_funcs fdecls =
	let found = List.exists (fun f -> f.name = "reserved" || f.name = "print") fdecls in
	if found then
		let func = List.find (fun f -> f.name = "reserved" || f.name = "print") fdecls in
		raise (Except("Reserved function name '" ^ func.name ^ "'!"))
	else fdecls

let analyze (prog: Ast.program) =
	let fdecls = check_for_builtin_funcs prog.fdecls in
	let function_table = List.fold_left check_function builtin_functions fdecls in
	(*let env = List.fold_left check_function builtin_functions fdecls*)
	{ sfdecls = function_table; sstatements = [] }