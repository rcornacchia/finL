open Ast
open Sast

exception Except of string

let builtin_functions = 
	[ { sname = "print";
		sformals = [];
		sbody = []; } ]

(*let vdecls_to_svdecls (vdecl: Ast.var_decl) =
	{ sdtype = vdecl.dtype; svname = vdecl.vname }

let formals_to_sformals formals =
	List.map vdecls_to_svdecls formals*)

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
	| Vdecl(v) -> Vdecl(v)
	| Noexpr -> Noexpr

let statement_to_sstatement = function
	Expr(expression) -> Expr(expression_to_sexpression expression)

(*let body_to_sbody body =
	List.map statements_to_sstatements body*)

let fdecl_to_sfdecl name (fdecl: Ast.func_decl) =
	(*let new_formals = formals_to_sformals fdecl.formals in
	let new_body = body_to_sbody fdecl.body in *)
	{ sname = name;
	  sformals = fdecl.formals;
	  sbody = fdecl.body; }

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
	let new_statements = List.map statement_to_sstatement prog.statements in
	(*let env = List.fold_left check_function builtin_functions fdecls*)
	{ sfdecls = function_table; sstatements = new_statements }