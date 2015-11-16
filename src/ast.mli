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
  fname : string;
  formals : string list;
  funcBody : statement list;
}

type program = {vdecls: string list; fdecls: func_decl list }
