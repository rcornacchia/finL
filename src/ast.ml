type op = Add | Sub | Mult | Div | Equal | Less | Leq | Greater | Geq

type data_type =
  Inttype
  | Stringtype

type expression =
  Int of int
  | String of string
  | Var of string
  | Binop of expression * op * expression
  | Assign of string * expression
  | Call of string * expression
  | Vdecl of data_type * string
  | Noexpr

type statement =
  Expr of expression

type func_decl = {
  (*rtype : string;*)
  name : string;
  formals : expression list;
  body : statement list;
}

type program = { 
    statements : statement list;
    fdecls : func_decl list;
}

let string_of_program (prog: program) =
  "string of program\n"