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
  | Vdecl of var_decl
  | Noexpr

type statement =
  Expr of expression

type func_decl = {
  (*rtype : string;*)
  name : string;
  formals : var_decl list;
  body : statement list;
}

type program = { 
    statements : statement list;
    fdecls : func_decl list;
}

let string_of_program (prog: program) =
  "string of program\n"