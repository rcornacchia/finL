open Ast

(*type svar_decl = {
  sdtype : data_type;
  svname : string;
}*)

(*type sexpression =
  Int of int
  | String of string
  | Var of string
  | Binop of sexpression * op * sexpression
  | Assign of string * sexpression
  | Call of string * sexpression
  | Vdecl of svar_decl
  | Noexpr

type sstatement =
  Expr of expression *)

type sfunc_decl = {
  (*rtype : string;*)
  sname : string;
  sformals : var_decl list;
  sbody : statement list;
  (*env : some kind of symbol table*)
}

type sprogram = { 
    sstatements : statement list;
    sfdecls : sfunc_decl list;
}

let string_of_sprogram (prog: sprogram) =
	"string of sprogram\n"