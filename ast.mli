type op = Add

type expression =
  Int of int
  | Var of string
  | Binop of expression * op * expression
  | Assign of string * expression
  | Call of string * expression list 