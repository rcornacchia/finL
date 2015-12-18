open Ast
open Sast

exception Except of string

let builtin_functions = 
	[ { name = "print";
		formals = [];
		body = []; } ]

(*let vdecls_to_svdecls (vdecl: Ast.var_decl) =
	{ sdtype = vdecl.dtype; svname = vdecl.vname }*)

let check_for_main name expression =
	let new_name = 
		if name = "main" then "reserved"
		else name
	in Call(new_name, expression)

let expression_to_sexpression = function
	Int(i) -> Int(i)
	| String(s) -> String(s)
	| Var(v) -> Var(v)
	| Binop(e1, o, e2) -> Binop(e1, o, e2)
	| Assign(a1, a2) -> Assign(a1, a2)
	| Call(c1, c2) -> check_for_main c1 c2
	| Noexpr -> Noexpr

let statement_to_sstatement = function
	Expr(expression) -> Expr(expression_to_sexpression expression)
	| Vdecl(v) -> Vdecl(v)

(*let body_to_sbody body =
	List.map statements_to_sstatements body*)

let analyze_formals variables (variable: Ast.var_decl) =
	let found = List.exists (fun f -> variable.vname = f.vname) variables in
	if found then raise (Except("Formal parameter " ^ variable.vname ^ " already defined!"))
	else variable :: variables 

let analyze_function_signature name (fdecl: Ast.func_decl) =
	let new_formals = List.fold_left analyze_formals [] fdecl.formals in
	{ name = name;
	  formals = List.rev new_formals;
	  body = fdecl.body; }

let check_function_name funcs (fdecl: Ast.func_decl) =
	let name = 
		if fdecl.name = "main" then "reserved"
		else fdecl.name
	in
	let found = List.exists (fun f -> f.name = name) funcs in
	if found then raise (Except(fdecl.name ^ " already exists!"))
	else let updated_fdecl = analyze_function_signature name fdecl (* probably need environment here -> MAYBE NOT *) in
	updated_fdecl :: funcs

let check_for_builtin_funcs fdecls =
	let found = List.exists (fun f -> f.name = "reserved" || f.name = "print") fdecls in
	if found then
		let func = List.find (fun f -> f.name = "reserved" || f.name = "print") fdecls in
		raise (Except("Reserved function name '" ^ func.name ^ "'!"))
	else fdecls

(*let analyze_function fdecl =*)


let analyze (prog: Ast.program) =
	prog
	(*let fdecls = check_for_builtin_funcs prog.fdecls in
	let function_table = List.fold_left check_function_name builtin_functions fdecls in
	let function_table = List.map analyze_function function_table in
	(*let env =*) 
	let new_statements = List.map statement_to_sstatement prog.statements in
	(*let env = List.fold_left check_function builtin_functions fdecls*)
	{ sfdecls = function_table; sstatements = new_statements }*)