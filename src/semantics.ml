open Ast
open Sast
open String

exception Except of string

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
	function_table = [];
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
	(try ignore (List.find (fun f -> f.sname = sname) env.function_table); raise (Except("Function '" ^ name ^ "' is already defined!")) (* overwrite_function_test.finl *)
	with Not_found -> sname)

let formal_to_sformal sformals (formal: Ast.var_decl) =
	let found = List.exists (fun sf -> formal.vname = sf.vname) sformals in
	if found then raise (Except("Formal parameter '" ^ formal.vname ^ "' is already defined!")) (* bad_formals_test.finl *)
	else formal :: sformals

let analyze_vdecl env (vdecl: Ast.var_decl) =
	let found = List.exists (fun symbol -> symbol.vname = vdecl.vname) env.symbol_table in
	if found then raise (Except("Variable '" ^ vdecl.vname ^ "' is already defined!")) (* redeclare_variable_test.finl *)
	else vdecl

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

let check_string_binop (sexpr1: Sast.sexpression) (op: Ast.binop) (sexpr2: Sast.sexpression) =
	match op with
		Add -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Stringtype; }
		| Equal -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Less -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Leq -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Greater -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| Geq -> { sexpr = Sbinop(sexpr1, op, sexpr2); sdtype = Inttype; }
		| _ -> raise (Except("Operator '" ^ Ast.string_of_binop op ^ "' is not supported for strings!"))

let check_number_binop (sexpr1: Sast.sexpression) (op: Ast.binop) (sexpr2: Sast.sexpression) =
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

let binop_to_sbinop (sexpr1: Sast.sexpression) (op: Ast.binop) (sexpr2: Sast.sexpression) = 
	let type1 = sexpr1.sdtype
	and type2 = sexpr2.sdtype in
	match (type1, type2) with
		(Stringtype, Stringtype) -> check_string_binop sexpr1 op sexpr2
		| (t, Stringtype) -> raise (Except("Cannot do binary operation on type '" ^ Ast.string_of_data_type t ^ "' and type 'string'!"))
		| (Stringtype, t) -> raise (Except("Cannot do binary operation on type 'string' and type '" ^ Ast.string_of_data_type t ^ "'."))
		| (Stocktype, t) -> raise (Except("Type 'stock' does not support binary operations!."))
		| (t, Stocktype) -> raise (Except("Type 'stock' does not support binary operations!."))
		| (Ordertype, t) -> raise (Except("Type 'order' does not support binary operations!."))
		| (t, Ordertype) -> raise (Except("Type 'order' does not support binary operations!."))
		| (_, _) ->	check_number_binop sexpr1 op sexpr2

let unop_to_sunop env (u: Ast.unop) (se: Sast.sexpression) =
		let typ = se.sdtype in
		match typ with
			Inttype -> { sexpr = Sunop(u, se); sdtype = Inttype; }
			| Floattype -> { sexpr = Sunop(u, se); sdtype = Floattype; }
			| t -> raise (Except("Unary operations are not supported for type '" ^ Ast.string_of_data_type typ ^ "'!"))		

let split_access acc =
	let str = sub acc 2 ((length acc) - 2) in
	trim str

let rec expression_to_sexpression env (expression: Ast.expression) =
	match expression with
		Int(i) -> 				{ sexpr = Sint(i); sdtype = Inttype; }
		| String(s) -> 			{ sexpr = Sstring(s); sdtype = Stringtype; }
		| Float(f) -> 			{ sexpr = Sfloat(f); sdtype = Floattype; }
		| Stock(stk) ->			{ sexpr = Sstock(stk); sdtype = Stocktype; } (* CHECK FOR VALID TICKER??? *)
		| Order(i, ord) ->		let new_ord = (expression_to_sexpression env ord) in
								if new_ord.sdtype = Stocktype then
									({ sexpr = Sorder(i, new_ord); sdtype = Ordertype; })
								else raise (Except("Invalid order!"))

		| Var(v) -> 			var_to_svar env v

		| Unop(op, e) -> 		unop_to_sunop env op (expression_to_sexpression env e)

		| Binop(e1, o, e2) -> 	let se1 = expression_to_sexpression env e1 in
								let se2 = expression_to_sexpression env e2 in
								binop_to_sbinop se1 o se2

		| Access(e, s) ->		let acc = split_access s
								and checked_expression = expression_to_sexpression env e in
								{ sexpr = Saccess(checked_expression, acc); sdtype = Stringtype; } (* CHECK RETURN TYPE???/VALID ACCESS? *)

		| Assign(a, e) -> 		let sexpression = expression_to_sexpression env e in
								let checked_sexpression = check_assign env a sexpression in
								{ sexpr = Sassign(a, checked_sexpression); sdtype = checked_sexpression.sdtype; }

		| Aassign(aa, e) -> 	let sexpression = expression_to_sexpression env e in
								let checked_sexpression = check_assign env aa sexpression in
								let typ = checked_sexpression.sdtype in
								if typ <> Inttype && typ <> Floattype && typ <> Stringtype then
									(raise (Except("Add assignment is undefined for type '" ^ Ast.string_of_data_type typ ^ "'!")))
								else { sexpr = Saassign(aa, checked_sexpression); sdtype = checked_sexpression.sdtype; }

		| Sassign(sa, e) ->		let sexpression = expression_to_sexpression env e in
								let checked_sexpression = check_assign env sa sexpression in
								let typ = checked_sexpression.sdtype in
								if typ <> Inttype && typ <> Floattype then
									(raise (Except("Add assignment is undefined for type '" ^ Ast.string_of_data_type typ ^ "'!")))
								else { sexpr = Ssassign(sa, checked_sexpression); sdtype = checked_sexpression.sdtype; }

		| Massign(ma, e) ->		let sexpression = expression_to_sexpression env e in
								let checked_sexpression = check_assign env ma sexpression in
								let typ = checked_sexpression.sdtype in
								if typ <> Inttype && typ <> Floattype then
									(raise (Except("Add assignment is undefined for type '" ^ Ast.string_of_data_type typ ^ "'!")))
								else { sexpr = Smassign(ma, checked_sexpression); sdtype = checked_sexpression.sdtype; }

		| Dassign(da, e) ->		let sexpression = expression_to_sexpression env e in
								let checked_sexpression = check_assign env da sexpression in
								let typ = checked_sexpression.sdtype in
								if typ <> Inttype && typ <> Floattype then
									(raise (Except("Add assignment is undefined for type '" ^ Ast.string_of_data_type typ ^ "'!")))
								else { sexpr = Sdassign(da, checked_sexpression); sdtype = checked_sexpression.sdtype; }


		| Call(c, el) -> 		let sname = check_for_main c in (* no_return_test.finl *)
						 		(try let func = List.find (fun f -> f.sname = sname) env.function_table in
						 			(try let new_el = List.map2 (fun f e -> let sexpr = expression_to_sexpression env e in 
						 										if f.dtype <> sexpr.sdtype then (raise (Except("Function parameter type mismatch!"))) (* parameter_type_mismatch_test.finl *)
						 										else sexpr) func.sformals el
						 										in { sexpr = Scall(sname, new_el); sdtype = func.srtype; }
						 			with Invalid_argument _ -> raise (Except("Wrong argument length to function '" ^ check_for_reserved func.sname ^ "'."))) (* arg_length_test.finl *)
						 		with Not_found -> raise (Except("Function '" ^ c ^ "' not found!"))) (* uninitialized_call_test.finl *)
		| Noexpr -> { sexpr = Snoexpr; sdtype = Voidtype; }

let check_estatement (sexpr: Sast.sexpression) =
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
	else raise (Except("Return statements cannot be used outside of functions!")) (* outside_return_test.finl *)

let rec statement_to_sstatement env (statement: Ast.statement) =
	match statement with
		If(ex, sl) -> let checked_expression = expression_to_sexpression env ex in (* handle multiple returns!!! *)
					  let typ = checked_expression.sdtype in
					  if typ <> Inttype && typ <> Floattype then (raise (Except("If expressions only take numerical types!")))
					  else let if_env = { function_table = env.function_table;
										  symbol_table = env.symbol_table;
										  checked_statements = [];
										  env_scope = env.env_scope; }
						   in
					  	   let if_env = List.fold_left statement_to_sstatement if_env sl in
					  	   let checked_statement = Sif(checked_expression, if_env.checked_statements) in
					  	   let new_env = { function_table = env.function_table;
								     	   symbol_table = env.symbol_table; 
								     	   checked_statements = checked_statement :: env.checked_statements; 
								     	   env_scope = env.env_scope; }
						   in new_env

		| While(ex, sl) -> let checked_expression = expression_to_sexpression env ex in (* should you be allowed to return from a while? YES *)
					  	   let typ = checked_expression.sdtype in
					  			if typ <> Inttype && typ <> Floattype then (raise (Except("While expressions only take numerical types!")))
					  			else let while_env = { function_table = env.function_table;
										  			   symbol_table = env.symbol_table;
										  			   checked_statements = [];
										  			   env_scope = env.env_scope; }
						   in
					  	   let while_env = List.fold_left statement_to_sstatement while_env sl in
					  	   let checked_statement = Swhile(checked_expression, while_env.checked_statements) in
					  	   let new_env = { function_table = env.function_table;
								     	   symbol_table = env.symbol_table; 
								     	   checked_statements = checked_statement :: env.checked_statements; 
								     	   env_scope = env.env_scope; }
						   in new_env

		| When(ex, sl) -> let checked_expression = expression_to_sexpression env ex in (* should you be allowed to return from a when? *)
					  	  let typ = checked_expression.sdtype in
					  		if typ <> Inttype && typ <> Floattype then (raise (Except("When expressions only take numerical types!")))
					  		else let when_env = { function_table = env.function_table;
										  		   symbol_table = env.symbol_table;
										  		   checked_statements = [];
										  		   env_scope = env.env_scope; }
							in
					  	   	let when_env = List.fold_left statement_to_sstatement when_env sl in
					  	   	let checked_statement = Swhen(checked_expression, when_env.checked_statements) in
					  	   	let new_env = { function_table = env.function_table;
								     	   symbol_table = env.symbol_table; 
								     	   checked_statements = checked_statement :: env.checked_statements; 
								     	   env_scope = env.env_scope; }
						   	in new_env

		| Expr(e) -> let checked_expression = expression_to_sexpression env e in
				   	 let checked_statement = Sexpr(check_estatement checked_expression) in
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
		| Ret(r) -> let checked_expression = check_return env (expression_to_sexpression env r) in (* break out of scope when return is found FLAG IN ENV?? *)
					let checked_statement = Sret(checked_expression) in
					let new_env = { function_table = env.function_table;
									symbol_table = env.symbol_table;
									checked_statements = checked_statement :: env.checked_statements; 
									env_scope = env.env_scope; }
					in new_env

		| Buy(b) -> let checked_expression = expression_to_sexpression env b in
					if checked_expression.sdtype <> Ordertype then (raise (Except("'buy' keyword takes type 'order'!")))
					else let checked_statement = Sbuy(checked_expression) in
					let new_env = { function_table = env.function_table;
									symbol_table = env.symbol_table;
									checked_statements = checked_statement :: env.checked_statements;
									env_scope = env.env_scope; }
					in new_env

		| Sell(s) -> let checked_expression = expression_to_sexpression env s in
					 if checked_expression.sdtype <> Ordertype then (raise (Except("'buy' keyword takes type 'order'!")))
					 else let checked_statement = Ssell(checked_expression) in
					 let new_env = { function_table = env.function_table;
									 symbol_table = env.symbol_table;
									 checked_statements = checked_statement :: env.checked_statements;
									 env_scope = env.env_scope; }
					 in new_env
		| Print(ex) -> let checked_expression = expression_to_sexpression env ex in
					   if checked_expression.sdtype = Voidtype && checked_expression.sexpr <> Snoexpr then 
					   		(raise (Except("Cannot print 'void' type!")))
					   else let checked_statement = Sprint(checked_expression) in
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
				   		srtype = fdecl.rtype; }
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