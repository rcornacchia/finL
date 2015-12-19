open Ast
open Sast

exception Except of string

let builtin_functions = 
	[ {
		sname = "print";
		sformals = [];
		sbody = [];
		srtype = Voidtype; (*TEMPORARY*) 
		builtin = true; } ]

type scope = {
	scope_name : string;
	scope_rtype : Ast.data_type ;
}

type environment = {
	function_table : Sast.sfunc_decl list;
	symbol_table : Ast.var_decl list;
	checked_statements : Sast.sstatement list;
	env_scope : scope;
}

let root_env = {
	function_table = builtin_functions;
	symbol_table = [];
	checked_statements = [];
	env_scope = { scope_name = "reserved"; scope_rtype = Voidtype; };
}

let name_to_sname env name =
	let sname =
		if name = "reserved" then (raise (Except("'reserved' is a reserved function name!"))) (* reserved_test.finl *)
		else 
			if name = "main" then ("reserved")
			else name
	in
	(try
		let func = List.find (fun f -> f.sname = sname) env.function_table in
		if func.builtin then (raise (Except("Function '" ^ func.sname ^ "' is a built in function!"))) (* overwrite_print_test.finl *)
		else raise (Except("Function '" ^ name ^ "' is already defined!")) (* overwrite_function_test.finl *)
	with Not_found -> sname)

let formal_to_sformal sformals (formal: Ast.var_decl) =
	let found = List.exists (fun sf -> formal.vname = sf.vname) sformals in
	if found then raise (Except("Formal parameter '" ^ formal.vname ^ "' is already defined!")) (* bad_formals_test.finl *)
	else formal :: sformals

let analyze_vdecl env (vdecl: Ast.var_decl) =
	let found = List.exists (fun symbol -> symbol.vname = vdecl.vname) env.symbol_table in
	if found then raise (Except("Variable '" ^ vdecl.vname ^ "' is already defined!")) (* redeclare_variable_test.finl *)
	else vdecl

(*let rec check_type env (expression: Ast.expression) =
	match expression with
		Int(i) -> Inttype
		| String(s) -> Stringtype
		| Float(f) -> Floattype
		| Var(v) -> (try let symbol = List.find (fun s -> s.vname = v) env.symbol_table in
						symbol.dtype
					with Not_found -> raise (Except("Symbol '" ^ v ^ "' is uninitialized!"))) (* uninitialized_variable_test.finl *)
		| Binop(e1, o, e2) -> (match o with
								Equal -> Inttype
								| Less -> Inttype
								| Leq -> Inttype
								| Greater -> Inttype
								| Geq -> Inttype
								| And -> Inttype
								| Or -> Inttype
								| _ -> (match check_type env e1 with
											Stringtype -> Stringtype
											| Floattype -> Floattype
											| _ -> let is_int = (check_type env e2) = Inttype in
											 			 if is_int then (Inttype) else Floattype))
		| Assign(a, e) -> check_type env e
		| Aassign(aa, e) -> check_type env e
		| Sassign(sa, e) -> check_type env e
		| Massign(ma, e) -> check_type env e
		| Dassign(da, e) -> check_type env e
		| Call(c, el) -> (try let func = List.find (fun f -> f.sname = c) env.function_table in
							 func.srtype
						 with Not_found -> raise (Except("Function '" ^ c ^ "' not found!"))) (* uninitialized_call_test.finl *)
		| Noexpr -> Voidtype*)

let check_for_main name =
	let new_name = 
		if name = "main" then "reserved"
		else name
	in new_name

let check_for_reserved sname =
	let new_name = 
		if sname = "reserved" then "main"
		else sname
	in new_name

let check_assign env var (sexpression: Sast.sexpression) =
	(try let vdecl = List.find (fun s -> s.vname = var) env.symbol_table in
		let dtype = vdecl.dtype in
		let etype = sexpression.sdtype in
		let sametype = dtype = etype in
			if sametype then (sexpression)
			else let dstring = Ast.string_of_data_type dtype
				 and estring = Ast.string_of_data_type etype in 
				 raise (Except("Symbol '" ^ var ^ "' is of type '" ^ dstring ^ "', not of type '" ^ estring ^ "'.")) (* assign_type_mismatch_test.finl *)
	with Not_found -> raise (Except("Symbol '" ^ var ^ "' not initialized!"))) (* uninitialized_assignment_test.finl *)

let var_to_svar env name =
	(try let var = List.find (fun s -> s.vname = name) env.symbol_table in
		{ sexpr = Svar(name); sdtype = var.dtype; }
	with Not_found -> raise (Except("Symbol '" ^ name ^ "' is uninitialized!"))) (* uninitialized_variable_test.finl *)

let check_string_binop (sexpr1: Sast.sexpression) (op: Ast.op) (sexpr2: Sast.sexpression) =
	match op with
		Add -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Stringtype; }
		| Equal -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Less -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Leq -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Greater -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Geq -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| _ -> raise (Except("Operator '" ^ Ast.string_of_op op ^ "' is not supported for strings!"))

let check_number_binop (sexpr1: Sast.sexpression) (op: Ast.op) (sexpr2: Sast.sexpression) =
	match op with
		Equal -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Less -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Leq -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Greater -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Geq -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| And -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Or -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| _ -> (let typ = match sexpr1.sdtype with
							Floattype -> Floattype
							| _ -> let is_int = sexpr2.sdtype = Inttype in
								   if is_int then (Inttype) else Floattype
						  in { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = typ; })

let binop_to_sbinop (sexpr1: Sast.sexpression) (op: Ast.op) (sexpr2: Sast.sexpression) = 
	let type1 = sexpr1.sdtype
	and type2 = sexpr2.sdtype in
	match (type1, type2) with
		(Stringtype, Stringtype) -> check_string_binop sexpr1 op sexpr2 (* MUST CHECK STRING OPS!! *)
		| (t, Stringtype) -> raise (Except("Cannot do binary operation on type '" ^ Ast.string_of_data_type t ^ "' and type 'string'!"))
		| (Stringtype, t) -> raise (Except("Cannot do binary operation on type 'string' and type '" ^ Ast.string_of_data_type t ^ "'."))
		| (_, _) ->	check_number_binop sexpr1 op sexpr2 (* MUST CHECK OP!!! *)

let rec expression_to_sexpression env (expression: Ast.expression) =
	match expression with
		Int(i) -> 				{ sexpr = Sint(i); sdtype = Inttype; }
		| String(s) -> 			{ sexpr = Sstring(s); sdtype = Stringtype; }
		| Float(f) -> 			{ sexpr = Sfloat(f); sdtype = Floattype; }

		| Var(v) -> 			var_to_svar env v

		| Binop(e1, o, e2) -> 	let se1 = (expression_to_sexpression env e1) in
								let se2 = (expression_to_sexpression env e2) in
								binop_to_sbinop se1 o se2

		| Assign(a, e) -> 		let sexpression = expression_to_sexpression env e in
								let checked_sexpression = check_assign env a sexpression in
								{ sexpr = Sassign(a, checked_sexpression); sdtype = checked_sexpression.sdtype; }

		| Aassign(aa, e) -> 	let sexpression = expression_to_sexpression env e in
								let checked_sexpression = check_assign env aa sexpression in
								{ sexpr = Saassign(aa, checked_sexpression); sdtype = checked_sexpression.sdtype; }

		| Sassign(sa, e) ->		let sexpression = expression_to_sexpression env e in
								let checked_sexpression = check_assign env sa sexpression in
								{ sexpr = Ssassign(sa, checked_sexpression); sdtype = checked_sexpression.sdtype; }

		| Massign(ma, e) ->		let sexpression = expression_to_sexpression env e in
								let checked_sexpression = check_assign env ma sexpression in
								{ sexpr = Smassign(ma, checked_sexpression); sdtype = checked_sexpression.sdtype; }

		| Dassign(da, e) ->		let sexpression = expression_to_sexpression env e in
								let checked_sexpression = check_assign env da sexpression in
								{ sexpr = Sdassign(da, checked_sexpression); sdtype = checked_sexpression.sdtype; }

		| Call(c, el) -> 		let sname = check_for_main c in (* no_return_test.finl *)
						 		(try let func = List.find (fun f -> f.sname = sname) env.function_table in
						 			let builtin = func.builtin in (* CHECK # of args to print!!!!!!! *)
						 			if builtin then ({ sexpr = Scall(sname, List.map (fun e -> expression_to_sexpression env e) el); sdtype = func.srtype; })
						 			else
						 				(try let new_el = List.map2 (fun f e -> let sexpr = expression_to_sexpression env e in 
						 											if f.dtype <> sexpr.sdtype then (raise (Except("Function parameter type mismatch!"))) (* parameter_type_mismatch_test.finl *)
						 											else sexpr) func.sformals el
						 					 in { sexpr = Scall(sname, new_el); sdtype = func.srtype; }
						 				with Invalid_argument _ -> raise (Except("Wrong argument length to function '" ^ check_for_reserved func.sname ^ "'."))) (* arg_length_test.finl *)
						 		with Not_found -> raise (Except("Function '" ^ c ^ "' not found!"))) (* uninitialized_call_test.finl *)
		| Noexpr -> { sexpr = Snoexpr; sdtype = Voidtype; }

let check_statement (sexpr: Sast.sexpression) =
	match sexpr.sexpr with 
		Sassign(a, e) -> sexpr
		| Saassign(aa, e1) -> sexpr
		| Ssassign(sa, e2) -> sexpr
		| Smassign(ma, e3) -> sexpr
		| Sdassign(da, e4) -> sexpr
		| Scall(c, el) -> sexpr
		| _ -> raise (Except("Not a statement!")) (* statement_test.finl *)

let check_return env (sexpression: Sast.sexpression) =
	let scope = env.env_scope in
	let fname = scope.scope_name in
	let within_func = fname <> "reserved" in
	if within_func then 
		(let rtype = scope.scope_rtype in
		let etype = sexpression.sdtype in
		let sametype = rtype = etype in
		if sametype then (sexpression)
		else raise (Except("Function '" ^ fname ^ "' returns type '" ^ Ast.string_of_data_type rtype ^ "', not type '" ^ Ast.string_of_data_type etype ^ "'."))) (* bad_return_test.finl *)
	else raise (Except("return statements cannot be used outside of functions!")) (* outside_return_test.finl *)

let statement_to_sstatement env (statement: Ast.statement) =
	match statement with
		Expr(e) -> let checked_expression = expression_to_sexpression env e in
				   let checked_statement = Sexpr(check_statement checked_expression) in
				   let new_env = { function_table = env.function_table;
								   symbol_table = env.symbol_table; 
								   checked_statements = checked_statement :: env.checked_statements; 
								   env_scope = env.env_scope; }
				   in new_env 
		| Vdecl(v) -> let checked_vdecl = analyze_vdecl env v in
					  let checked_statement = Svdecl(checked_vdecl) in
					  let new_env = { function_table = env.function_table;
									  symbol_table = checked_vdecl :: env.symbol_table; 
									  checked_statements = checked_statement :: env.checked_statements; 
									  env_scope = env.env_scope; } 
					  in new_env
		| Ret(r) -> let checked_expression = check_return env (expression_to_sexpression env r) in
					let checked_statement = Sret(checked_expression) in
					let new_env = { function_table = env.function_table;
									symbol_table = env.symbol_table;
									checked_statements = checked_statement :: env.checked_statements; 
									env_scope = env.env_scope; }
					in new_env
					
let check_for_sreturn = function 
	Sret(_) -> true
	| _ -> false

let fdecl_to_sfdecl env (fdecl: Ast.func_decl) = (* multiple_return_test.finl NEEDS FIX *)
	let checked_name = name_to_sname env fdecl.name in
	let checked_formals = List.fold_left formal_to_sformal [] fdecl.formals in
	let func_env = { function_table = env.function_table; 
					 symbol_table = checked_formals; 
					 checked_statements = []; 
					 env_scope = { scope_name = fdecl.name; scope_rtype = fdecl.rtype; }; }
	in 
	let func_env = List.fold_left statement_to_sstatement func_env fdecl.body in
	let void = fdecl.rtype = Voidtype
	and returns = List.exists check_for_sreturn func_env.checked_statements in
	if (void && not returns) || (not void && returns) then
		(let sfdecl = { sname = checked_name;
				   		sformals = List.rev checked_formals;
				   		sbody = List.rev func_env.checked_statements;
				   		srtype = fdecl.rtype;
				   		builtin = false; }
		in
		let new_env = { function_table = sfdecl :: env.function_table; 
						symbol_table = env.symbol_table;
						checked_statements = env.checked_statements;
						env_scope = { scope_name = "reserved"; scope_rtype = Voidtype; }; }
		in
		new_env)
	else if void then (raise (Except("Function '" ^ fdecl.name ^ "' should not return!")))
		 else (raise (Except("Function '" ^ fdecl.name ^ "' does not have a return statement!"))) (* no_return_test.finl *)

let analyze_line env (line: Ast.line) =
	match line with
		Stmt(s) -> statement_to_sstatement env s
		| Fdecl(f) -> fdecl_to_sfdecl env f

let analyze (program: Ast.program) =
	let new_env = List.fold_left analyze_line root_env program.lines in
	let sprogram = { sfunc_decls = new_env.function_table; 
					 sstatements = List.rev new_env.checked_statements; }
	in sprogram