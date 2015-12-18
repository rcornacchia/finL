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

let check_function name = (* HAVE SOME BUILTIN FUNCTIONALITY HERE *)
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

let compile_statement = function
  Expr(expr) -> compile_expression expr ^ ";"
  | Vdecl(v) -> compile_vdecl v ^ ";"

let compile_sfdecl (func: Sast.sfunc_decl) =
  "public static void " ^
  func.sname ^
  "(" ^
  String.concat ", " (List.map compile_vdecl func.sformals) ^
  ") {\n" ^
  String.concat "\n" (List.map compile_statement func.sbody) ^
  "\n}"

let compile (sprogram: Sast.sprogram) (filename: string) =
  "public class " ^ 
  filename ^ 
  " {\n" ^
  String.concat "\n" (List.map compile_sfdecl sprogram.sfunc_decls) ^
  "\npublic static void main(String[] args) {\n" ^
  String.concat "\n" (List.map compile_statement sprogram.statements) ^
  "\n}\n}"