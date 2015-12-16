type op = Add | Sub | Mult | Div | Equal | Less | Leq | Greater | Geq

type sdata_type =
  Inttype
  | Stringtype

type svar_decl = {
  sdtype : sdata_type;
  svname : string;
}

type sexpression =
  Int of int
  | String of string
  | Var of string
  | Binop of sexpression * op * sexpression
  | Assign of string * sexpression
  | Call of string * sexpression
  | Vdecl of svar_decl
  | Noexpr

type sstatement =
  Expr of sexpression 

type sfunc_decl = {
  (*rtype : string;*)
  sname : string;
  sformals : svar_decl list;
  sbody : sstatement list;
}

type sprogram = { 
    sstatements : sstatement list;
    sfdecls : sfunc_decl list;
}

let string_of_sprogram (prog: sprogram) =
	"string of sprogram\n"