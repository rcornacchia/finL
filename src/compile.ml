open Ast
open Sast
open String

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
  "FinlLib.boolean_to_int(" ^ bool_string ^ ")"

let sexpr_to_boolean sexpr_string =
  "FinlLib.num_to_boolean(" ^ sexpr_string ^ ")"

let compile_compare sexpr_string1 op_string sexpr_string2 is_string_compare =
  let str = if is_string_compare then ("FinlLib.compare_strings(" ^ sexpr_string1 ^ ", \"" ^ op_string ^ "\", " ^ sexpr_string2 ^ ")")
            else sexpr_string1 ^ " " ^ op_string ^ " " ^ sexpr_string2
  in boolean_to_sexpr str

let string_of_stock ticker =
  let len = length ticker in
  let new_ticker = sub ticker 1 (len - 1) in
  "new FinlStock(\"" ^ new_ticker ^ "\")"

let string_of_order amt ord =
  let new_ord = match ord.sexpr with
    Svar(var) -> var
    | Sstock(stk) -> string_of_stock stk
    | _ -> "" (* parser should not allow any other tokens *)
  in "new FinlOrder(" ^ string_of_int amt ^ ", " ^ new_ord ^ ")"

let rec compile_sexpression (sexpr: Sast.sexpression) =
  match sexpr.sexpr with 
    Sstring(str) -> str
    | Sint(i) -> string_of_int i
    | Sfloat(f) -> string_of_float f
    | Sstock(stk) -> string_of_stock stk
    | Sorder(i, ord) -> string_of_order i ord
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
    | Saccess(expr, str) -> compile_sexpression expr ^ ".getRequest(\"" ^ str ^ "\")"
    | Sassign(var, expr) -> var ^ " = " ^ compile_sexpression expr
    | Saassign(avar, aexpr) -> avar ^ " += " ^ compile_sexpression aexpr
    | Ssassign(svar, sexpr) -> svar ^ " -= " ^ compile_sexpression sexpr
    | Smassign(mvar, mexpr) -> mvar ^ " *= " ^ compile_sexpression mexpr
    | Sdassign(dvar, dexpr) -> dvar ^ " /= " ^ compile_sexpression dexpr
    | Svar(str) -> str
    | Scall(name, exprlst) -> name ^ "(" ^ String.concat ", " (List.map compile_sexpression exprlst) ^ ")"
    | Snoexpr -> ""

let rec compile_sstatement = function
  Sexpr(expr) -> compile_sexpression expr ^ ";"
  | Sif(e, sl, sl2) -> let els = if (List.length sl2) = 0 then ("")
                       else "else {" ^ String.concat "\n" (List.map compile_sstatement sl2) ^ "}" in
                       "if (" ^ 
                       sexpr_to_boolean (compile_sexpression e) ^ 
                       ") {\n" ^
                       String.concat "\n" (List.map compile_sstatement sl) ^
                       "\n} " ^
                       els
  | Swhile(e, sl) -> "while (" ^ 
                  sexpr_to_boolean (compile_sexpression e) ^ 
                  ") {\n" ^
                  String.concat "\n" (List.map compile_sstatement sl) ^
                  "\n}"
  | Swhen((e1, op, e2), sl) -> "Thread when = new Thread(new Runnable() {\npublic void run(){\nwhile (true) {\n if (" ^
                               compile_sexpression e1 ^
                               " " ^
                               Ast.string_of_binop op ^
                               " " ^
                               compile_sexpression e2 ^
                               ") {\n" ^
                               String.concat "\n" (List.map compile_sstatement sl) ^
                               "\nbreak;\n}\ntry{ Thread.sleep(10000); } catch (InterruptedException ie) { System.out.println(\"Program execution interrupted!\"); }\n}\n}\n});\nwhen.start();"
  | Svdecl(v) -> compile_vdecl v ^ ";"
  | Sret(r) -> "return " ^ compile_sexpression r ^ ";"
  | Sbuy(b) -> "portfolio.buy(" ^ compile_sexpression b ^ ");"
  | Ssell(s) -> "portfolio.sell(" ^ compile_sexpression s ^ ");"
  | Sprint(e) -> (match e.sdtype with
                    Stocktype -> compile_sexpression e ^ ".printStock();"
                    | Ordertype -> compile_sexpression e ^ ".printOrder();"
                    | Voidtype -> "portfolio.printHoldings();"
                    | _ -> "System.out.println(" ^ compile_sexpression e ^ ");")
  | Sportfolio(str) -> "portfolio.switchWith(\"" ^ str ^ "\");"

let compile_sfdecl (func: Sast.sfunc_decl) =
  "public static " ^
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
  "try {\nFinlPortfolio portfolio;\n" ^
  "if (args.length > 0) { portfolio = new FinlPortfolio(args[0]);\n" ^
  "portfolio.csvPortfolioBuilder(); }\n" ^
  "else { portfolio = new FinlPortfolio(); }\n" ^
  String.concat "\n" (List.map compile_sstatement sprogram.sstatements) ^
  "\nportfolio.csvExport(); } catch (Exception e) { System.out.println(\"Library Error\"); }\n}\n}"