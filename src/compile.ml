open Ast
open Sast
open String

let check_function name = (* HAVE SOME BUILTIN FUNCTIONALITY HERE *)
  if name = "print" then "System.out.print"
  else name

let compile_dtype = function
  Inttype -> "int"
  | Stringtype -> "String"
  | Floattype -> "double"
  | Stocktype -> "FinlStock"
  | Ordertype -> "FinlOrder"
  | Voidtype -> "void"

let compile_vdecl (vdecl: Ast.var_decl) =
  compile_dtype vdecl.dtype ^ " " ^ vdecl.vname

let boolean_to_sexpr bool_string =
  "Test.boolean_to_int(" ^ bool_string ^ ")"

let sexpr_to_boolean sexpr_string =
  "Test.num_to_boolean(" ^ sexpr_string ^ ")"

let compile_compare sexpr_string1 op_string sexpr_string2 is_string_compare =
  let str = if is_string_compare then ("Test.compare_strings(" ^ sexpr_string1 ^ ", \"" ^ op_string ^ "\", " ^ sexpr_string2 ^ ")")
            else sexpr_string1 ^ " " ^ op_string ^ " " ^ sexpr_string2
  in boolean_to_sexpr str

let string_of_stock ticker =
  let len = length ticker in
  let new_ticker = sub ticker 1 (len - 1) in
  "new FinlStock(\"" ^ new_ticker ^ "\")"

let rec compile_sexpression (sexpr: Sast.sexpression) =
  match sexpr.sexpr with 
    Sstring(str) -> str
    | Sint(i) -> string_of_int i
    | Sfloat(f) -> string_of_float f
    | Sstock(stk) -> string_of_stock stk
    | Sunop(op, expr) -> (let unop = Ast.string_of_unop op in
                         match op with
                          Neg -> unop ^ compile_sexpression expr
                          | Not -> boolean_to_sexpr (unop ^ sexpr_to_boolean (compile_sexpression expr)))
    | Sbinop(expr1, op, expr2) -> (match op with 
                                    Pow -> "Math.pow(" ^ compile_sexpression expr1 ^ Ast.string_of_binop op ^ compile_sexpression expr2 ^ ")"
                                    | Equal -> compile_compare (compile_sexpression expr1) (Ast.string_of_binop op) (compile_sexpression expr2) (if expr1.sdtype = Stringtype then (true) else false)
                                    | Less -> compile_compare (compile_sexpression expr1) (Ast.string_of_binop op) (compile_sexpression expr2) (if expr1.sdtype = Stringtype then (true) else false)
                                    | Leq -> compile_compare (compile_sexpression expr1) (Ast.string_of_binop op) (compile_sexpression expr2) (if expr1.sdtype = Stringtype then (true) else false)
                                    | Greater -> compile_compare (compile_sexpression expr1) (Ast.string_of_binop op) (compile_sexpression expr2) (if expr1.sdtype = Stringtype then (true) else false)
                                    | Geq -> compile_compare (compile_sexpression expr1) (Ast.string_of_binop op) (compile_sexpression expr2) (if expr1.sdtype = Stringtype then (true) else false)
                                    | And -> boolean_to_sexpr (sexpr_to_boolean (compile_sexpression expr1) ^ " " ^ Ast.string_of_binop op ^ " " ^ sexpr_to_boolean (compile_sexpression expr2))
                                    | Or -> boolean_to_sexpr (sexpr_to_boolean (compile_sexpression expr1) ^ " " ^ Ast.string_of_binop op ^ " " ^ sexpr_to_boolean (compile_sexpression expr2))
                                    | _ -> compile_sexpression expr1 ^ " " ^ Ast.string_of_binop op ^ " " ^ compile_sexpression expr2)
    | Sassign(var, expr) -> var ^ " = " ^ compile_sexpression expr
    | Saassign(avar, aexpr) -> avar ^ " += " ^ compile_sexpression aexpr
    | Ssassign(svar, sexpr) -> svar ^ " -= " ^ compile_sexpression sexpr
    | Smassign(mvar, mexpr) -> mvar ^ " *= " ^ compile_sexpression mexpr
    | Sdassign(dvar, dexpr) -> dvar ^ " /= " ^ compile_sexpression dexpr
    | Svar(str) -> str
    | Scall(name, exprlst) -> check_function name ^ "(" ^ String.concat ", " (List.map compile_sexpression exprlst) ^ ")"
    | Snoexpr -> ""

let rec compile_sstatement = function
  Sexpr(expr) -> compile_sexpression expr ^ ";"
  | Sif(e, sl) -> "if (" ^ 
                  sexpr_to_boolean (compile_sexpression e) ^ 
                  ") {\n" ^
                  String.concat "\n" (List.map compile_sstatement sl) ^
                  "\n}"
  | Swhile(e, sl) -> "while (" ^ 
                  sexpr_to_boolean (compile_sexpression e) ^ 
                  ") {\n" ^
                  String.concat "\n" (List.map compile_sstatement sl) ^
                  "\n}"
  | Swhen(e, sl) -> "" (* TO DO *)
  | Svdecl(v) -> compile_vdecl v ^ ";"
  | Sret(r) -> "return " ^ compile_sexpression r ^ ";"

let compile_sfdecl (func: Sast.sfunc_decl) =
  if func.builtin then ("")
  else "public static " ^
       compile_dtype func.srtype ^
       " " ^
       func.sname ^
       "(" ^
       String.concat ", " (List.map compile_vdecl func.sformals) ^
       ") {\n" ^
       String.concat "\n" (List.map compile_sstatement func.sbody) ^
       "\n}"

let compile (sprogram: Sast.sprogram) (filename: string) =
  "import java.lang.Math;\n" ^
  "import bin.*;\n" ^
  "\npublic class " ^ 
  filename ^ 
  " {\n" ^
  String.concat "\n" (List.map compile_sfdecl sprogram.sfunc_decls) ^
  "\npublic static void main(String[] args) {\n" ^
  String.concat "\n" (List.map compile_sstatement sprogram.sstatements) ^
  "\n}\n}"