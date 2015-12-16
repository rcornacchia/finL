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

let compile_svdecl (svdecl: Sast.svar_decl) =
  let data_type = match svdecl.sdtype with
    Inttype -> "int"
    | Stringtype -> "String"
  in
  data_type ^ " " ^ svdecl.svname

let rec compile_sexpression = function
  String(str) -> str
  | Int(i) -> string_of_int i
  | Binop(expr1, op, expr2) -> compile_sexpression expr1 ^ string_of_op op ^ compile_sexpression expr2
  | Assign(var, expr) -> var ^ "=" ^ compile_sexpression expr
  | Var(str) -> str
  | Call(name, expr) -> check_function name ^ "(" ^ compile_sexpression expr ^ ")"
  | Vdecl(decl) -> compile_svdecl decl
  | Noexpr -> ""

let compile_sstatement = function
  Expr(expr) -> compile_sexpression expr ^ ";"

let compile_sfdecl (func: Sast.sfunc_decl) =
  "public static void " ^
  func.sname ^
  (* ADD ARGUMENTS!!!!!! -> EXPRESSIONS *)
  "() {\n" ^
  String.concat "\n" (List.map compile_sstatement func.sbody) ^
  "\n}"

let compile (prog: Sast.sprogram) (filename: string) =
  "public class " ^ 
  filename ^ 
  " {\n" ^
  String.concat "\n" (List.map compile_sfdecl prog.sfdecls) ^
  "\npublic static void main(String[] args) {\n" ^
  String.concat "\n" (List.map compile_sstatement prog.sstatements) ^
  "\n}\n}"