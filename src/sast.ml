open Ast

(*type svar_decl = {
  sdtype : data_type;
  svname : string;
}*)

type sexpression = Ast.expression * Ast.data_type

(*type sstatement =
  Expr of expression

type sfunc_decl = {
  (*rtype : string;*)
  sname : string;
  sformals : var_decl list;
  sbody : statement list;
  (*env : some kind of symbol table*)
}*)

type sprogram = { 
    sstatements : statement list;
    sfdecls : func_decl list;
}

let string_of_sprogram (prog: sprogram) =
	"string of sprogram\n"