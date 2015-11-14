type op = Add

type expression =
  Int of int
  | Var of string
  | Binop of expression * op * expression
  | Assign of string * expression
<<<<<<< HEAD
  | Call of string * expression list

type statement =
  Expr of expression

type func_decl = {
  fname : string;
  formals : string list;
  body : statement list;
}

type program = string list * func decl_list
=======
  | Call of string * expression list 
>>>>>>> 74d7fc5c58d73d3d9e4c5ce44c75ab4073e8d44c
