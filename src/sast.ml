type op = Add | Sub | Mult | Div | Equal | Less | Leq | Greater | Geq

type sdata_type =
  Inttype
  | Stringtype

type sexpression =
  Int of int
  | String of string
  | Var of string
  | Binop of sexpression * op * sexpression
  | Assign of string * sexpression
  | Call of string * sexpression
  | Vdecl of sdata_type * string
  | Noexpr

type sstatement =
  Expr of sexpression 

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