type op = Add | Sub | Mult | Div | Equal | Less | Leq | Greater | Geq

type sexpression =
  Int of int
  | String of string
  | Var of string
  | Binop of sexpression * op * sexpression
  | Assign of string * sexpression
  | Call of string * sexpression
  | Noexpr

type sstatement =
  Expr of sexpression
  | Intdecl of string
  | Stringdecl of string

type sfunc_decl = {
  (*rtype : string;*)
  sname : string;
  sformals : sexpression list;
  sbody : sstatement list;
}

type sprogram = { 
    sstatements : sstatement list;
    sfdecls : sfunc_decl list;
}

let string_of_sprogram (prog: sprogram) =
	"string of sprogram\n"