type op = Add | Sub | Mult | Div | Equal | Less | Leq | Greater | Geq

type expression =
  Int of int
  | Var of string
  | Binop of expression * op * expression
  | Assign of string * expression
  | Call of string * expression

type statement =
  Expr of expression

type func_decl = {
  (*rtype : string;*)
  name : string;
  formals : string list;
  body : statement list;
}

type program = string list * func_decl list;
