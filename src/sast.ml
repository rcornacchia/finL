open Ast

(*type svar_decl = {
  sdtype : data_type;
  svname : string;
}*)

(*type environment =
	{ (*variables : Ast.var_decl list;*)
	  functions : Sast.sfunc_decl list; }*)

type sexpression = Ast.expression * Ast.data_type

(*type sstatement =
  Expr of expression*)

(*type sfunc_decl = {
  (*rtype : string;*)
  sname : string;
  sformals : var_decl list;
  sbody : statement list;
  (*env : sfunc_decl list;*)
}*)

type sprogram = { 
    statements : statement list;
    fdecls : func_decl list;
}

let string_of_sprogram (prog: sprogram) =
	"string of sprogram\n"