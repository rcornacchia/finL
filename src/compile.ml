open Ast
open Sast

let string_of_op = function
	Add -> "+"
	| Sub -> "-"
	| Mult -> "*"
	| Div -> "/"
	| Equal -> "=="
	| Less -> "<"
	| Leq -> "<="
	| Greater -> ">"
	| Geq -> ">="

let check_function (name: string) =
  if name = "print" then "System.out.print"
  else name

let compile_vdecl (vdecl: Ast.var_decl) =
  let data_type = match vdecl.dtype with
    Inttype -> "int"
    | Stringtype -> "String"
  in
  data_type ^ " " ^ vdecl.vname

let rec compile_expression = function
  String(str) -> str
  | Int(i) -> string_of_int i
  | Binop(expr1, op, expr2) -> compile_expression expr1 ^ string_of_op op ^ compile_expression expr2
  | Assign(var, expr) -> var ^ "=" ^ compile_expression expr
  | Var(str) -> str
  | Call(name, exprlst) -> check_function name ^ "(" ^ String.concat ", " (List.map compile_expression exprlst) ^ ")"
  | Noexpr -> ""

let compile_sstatement = function
  Expr(expr) -> compile_expression expr ^ ";"
  | Vdecl(v) -> compile_vdecl v ^ ";"

let compile_sfdecl (func: Ast.func_decl) =
  "public static void " ^
  func.name ^
  "(" ^
  String.concat ", " (List.map compile_vdecl func.formals) ^
  ") {\n" ^
  String.concat "\n" (List.map compile_sstatement func.body) ^
  "\n}"

let compile (prog: Ast.program) (filename: string) =
  prog
  (*"public class " ^ 
  filename ^ 
  " {\n" ^
  String.concat "\n" (List.map compile_sfdecl prog.fdecls) ^
  "\npublic static void main(String[] args) {\n" ^
  String.concat "\n" (List.map compile_sstatement prog.statements) ^
  "\n}\n}"*)