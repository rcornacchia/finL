type op = Add

type expression =
  Int of int
  | Var of string
  | Binop of expression * op * expression
  | Assign of string * expression
  | Call of string * expression list

type statement =
  Expr of expression

type func_decl = {
  fname : string;
  formals : string list;
  body : statement list;
}

type program = string list * func decl_list
