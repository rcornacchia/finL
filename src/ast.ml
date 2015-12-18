type op = Add | Sub | Mult | Div | Equal | Less | Leq | Greater | Geq

type data_type =
  Inttype
  | Stringtype

type var_decl = {
  dtype : data_type;
  vname : string;
}

type expression =
  Int of int
  | String of string
  | Var of string
  | Binop of expression * op * expression
  | Assign of string * expression
  | Call of string * expression list
  | Noexpr

type statement =
  Expr of expression
  | Vdecl of var_decl

type func_decl = {
  (*rtype : string;*)
  name : string;
  formals : var_decl list;
  body : statement list;
}

type line =
  Stmt of statement
  | Fdecl of func_decl

type program = { 
    lines : line list;
}

let string_of_op = function
  Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Equal -> "="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">" 
  | Geq -> ">="

let string_of_data_type = function
  Inttype -> "int"
  | Stringtype -> "string"

let rec string_of_expression = function
  Int(i) -> string_of_int i
  | String(s) -> s
  | Var(v) -> v
  | Binop(e1, o, e2) -> string_of_expression e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expression e2
  | Assign(a, e) -> a ^ " = " ^ string_of_expression e 
  | Call(c, el) -> c ^ "(" ^ String.concat ", " (List.map string_of_expression el) ^ ")"
  | Noexpr -> "NOEXPR"

let string_of_vdecl (vdecl: var_decl) = 
  "vdecl{" ^ vdecl.vname ^ " -> " ^ string_of_data_type vdecl.dtype ^ "}"

let string_of_statement = function
  Expr(e) -> "expression{" ^ string_of_expression e ^ "}"
  | Vdecl(v) -> string_of_vdecl v

let string_of_fdecl (fdecl: func_decl) =
  "name{" ^ 
  fdecl.name ^ 
  "} formals{" ^ 
  String.concat ", " (List.map string_of_vdecl fdecl.formals) ^ 
  "} body{\nstatement{" ^
  String.concat "}\nstatement{" (List.map string_of_statement fdecl.body) ^
  "}\n}"

let string_of_line = function
  Stmt(s) -> "statement{" ^ string_of_statement s ^ "}"
  | Fdecl(f) -> "fdecl{\n" ^ string_of_fdecl f ^ "\n}"

let string_of_program (prog: program) =
  "program{\n" ^ String.concat "\n" (List.map string_of_line prog.lines) ^ "\n}\n"