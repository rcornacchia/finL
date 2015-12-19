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
  | Mod -> "%"
  | Pow -> ", "

let check_function name = (* HAVE SOME BUILTIN FUNCTIONALITY HERE *)
  if name = "print" then "System.out.print"
  else name

let compile_dtype = function
  Inttype -> "int"
  | Stringtype -> "String"
  | Floattype -> "double"
  | Voidtype -> "void"

let compile_vdecl (vdecl: Ast.var_decl) =
  compile_dtype vdecl.dtype ^ " " ^ vdecl.vname

let rec compile_expression = function
  String(str) -> str
  | Int(i) -> string_of_int i
  | Float(f) -> string_of_float f
  | Binop(expr1, op, expr2) -> let pow = op = Pow in
                               if pow then ("Math.pow(" ^ compile_expression expr1 ^ string_of_op op ^ compile_expression expr2 ^ ")")
                               else compile_expression expr1 ^ " " ^ string_of_op op ^ " " ^ compile_expression expr2 
  | Assign(var, expr) -> var ^ " = " ^ compile_expression expr
  | Aassign(avar, aexpr) -> avar ^ " += " ^ compile_expression aexpr
  | Sassign(svar, sexpr) -> svar ^ " -= " ^ compile_expression sexpr
  | Massign(mvar, mexpr) -> mvar ^ " *= " ^ compile_expression mexpr
  | Dassign(dvar, dexpr) -> dvar ^ " /= " ^ compile_expression dexpr
  | Var(str) -> str
  | Call(name, exprlst) -> check_function name ^ "(" ^ String.concat ", " (List.map compile_expression exprlst) ^ ")"
  | Noexpr -> ""

let compile_statement = function
  Expr(expr) -> compile_expression expr ^ ";"
  | Vdecl(v) -> compile_vdecl v ^ ";"
  | Ret(r) -> "return " ^ compile_expression r ^ ";"

let compile_sfdecl (func: Sast.sfunc_decl) =
  if func.builtin then ("")
  else "public static " ^
       compile_dtype func.srtype ^
       " " ^
       func.sname ^
       "(" ^
       String.concat ", " (List.map compile_vdecl func.sformals) ^
       ") {\n" ^
       String.concat "\n" (List.map compile_statement func.sbody) ^
       "\n}"

let compile (sprogram: Sast.sprogram) (filename: string) =
  "import java.lang.Math;\npublic class " ^ 
  filename ^ 
  " {\n" ^
  String.concat "\n" (List.map compile_sfdecl sprogram.sfunc_decls) ^
  "\npublic static void main(String[] args) {\n" ^
  String.concat "\n" (List.map compile_statement sprogram.statements) ^
  "\n}\n}"