open Ast
open Sast

exception Except of string

let builtin_functions = 
	[ {
		sname = "print";
		sformals = [];
		sbody = []; 
		builtin = true; };
	  (*{ 
	  	name = "reserved";
	  	formals = [];
	  	body = [];
	  	builtin = [];
	  }*) ]

type environment = {
	function_table : Sast.sfunc_decl list;
	symbol_table : Ast.var_decl list;
	checked_lines : Sast.sline list;
}

let root_env = {
	function_table = builtin_functions;
	symbol_table = [];
	checked_lines = [];
}

let name_to_sname env name =
	let sname =
		if name = "reserved" then (raise (Except("'reserved' is a reserved function name!")))
		else 
			if name = "main" then ("reserved")
			else name
	in
	let found = List.exists (fun f -> f.sname = sname) env.function_table in
	if found then
		(let func = List.find (fun f -> f.sname = sname) env.function_table in
		if func.builtin then (raise (Except(func.sname ^ " is a built in function!")))
		else raise (Except(func.sname ^ " is already defined!")))
	else sname

let formal_to_sformal sformals (formal: Ast.var_decl) =
	let found = List.exists (fun sf -> formal.vname = sf.vname) sformals in
	if found then raise (Except("Formal parameter '" ^ formal.vname ^ "' is already defined!"))
	else formal :: sformals

let analyze_vdecl env (vdecl: Ast.var_decl) =
	let found = List.exists (fun symbol -> symbol.vname = vdecl.vname) env.symbol_table in
	if found then raise (Except("Variable '" ^ vdecl.vname ^ "' is already defined!"))
	else vdecl

let check_for_main name exprlst =
	let new_name = 
		if name = "main" then "reserved"
		else name
	in Call(new_name, exprlst)

let analyze_expression env (expression: Ast.expression) = (* DO TYPE CHECKING!!! *)
	match expression with
		Int(i) -> Int(i)
		| String(s) -> String(s)
		| Var(v) -> Var(v)
		| Binop(e1, o, e2) -> Binop(e1, o, e2)
		| Assign(a, e) -> Assign(a, e)
		| Call(c, el) -> check_for_main c el
		| Noexpr -> Noexpr

let analyze_statement env (statement: Ast.statement) =
	match statement with
		Expr(e) -> let checked_expression = analyze_expression env e in
				   let checked_line = Stmt(Expr(checked_expression)) in
				   let new_env = { function_table = env.function_table;
								   symbol_table = env.symbol_table; 
								   checked_lines = checked_line :: env.checked_lines; }
				   in new_env 
		| Vdecl(v) -> let checked_vdecl = analyze_vdecl env v in
					  let checked_line = Stmt(Vdecl(checked_vdecl)) in
					  let new_env = { function_table = env.function_table;
									  symbol_table = checked_vdecl :: env.symbol_table; 
									  checked_lines = checked_line :: env.checked_lines; } 
					  in new_env
					

let fdecl_to_sfdecl env (fdecl: Ast.func_decl) =
	let checked_name = name_to_sname env fdecl.name in
	let checked_formals = List.fold_left formal_to_sformal [] fdecl.formals in
	let func_env = { function_table = env.function_table; 
					 symbol_table = checked_formals; 
					 checked_lines = env.checked_lines; }
	in 
	let func_env = List.fold_left analyze_statement func_env fdecl.body in
	let sfdecl = { sname = checked_name;
				   sformals = checked_formals;
				   sbody = fdecl.body;
				   builtin = false; }
	in
	let new_env = { function_table = sfdecl :: env.function_table; 
					symbol_table = env.symbol_table;
					checked_lines = Fdecl(sfdecl) :: env.checked_lines; }
	in
	new_env

let line_to_sline env (line: Ast.line) =
	match line with
		Stmt(s) -> analyze_statement env s
		| Fdecl(f) -> fdecl_to_sfdecl env f

let analyze (program: Ast.program) =
	let new_env = List.fold_left line_to_sline root_env program.lines in
	let sprogram = { slines = List.rev new_env.checked_lines; } in
	sprogram