open Ast

(*type svar_decl = {
  sdtype : data_type;
  svname : string;
}*)

(*type environment =
	{ (*variables : Ast.var_decl list;*)
	  functions : Sast.sfunc_decl list; }

type sexpression = Ast.expression * Ast.data_type

(*type sstatement =
  Expr of expression*)*)

type sfunc_decl = {
  (*rtype : string;*)
  sname : string;
  sformals : Ast.var_decl list;
  sbody : Ast.statement list;
  builtin : bool;
}

type sline =
  Stmt of Ast.statement
  | Fdecl of sfunc_decl

type sprogram = { 
    slines : sline list;
}

let string_of_sfdecl (sfdecl: sfunc_decl) =
  "sname{" ^ 
  sfdecl.sname ^ 
  "} sformals{" ^ 
  String.concat ", " (List.map Ast.string_of_vdecl sfdecl.sformals) ^ 
  "} builtin { " ^
  string_of_bool sfdecl.builtin ^
  "} sbody{\nstatement{" ^
  String.concat "}\nstatement{" (List.map Ast.string_of_statement sfdecl.sbody) ^
  "}\n}"

let string_of_sline = function
  Stmt(s) -> "statement{" ^ Ast.string_of_statement s ^ "}"
  | Fdecl(f) -> "sfdecl{\n" ^ string_of_sfdecl f ^ "\n}"

let string_of_sprogram (sprog: sprogram) =
	"sprogram{\nsline{\n" ^ String.concat "\n}\nsline{\n" (List.map string_of_sline sprog.slines) ^ "\n}\n}\n"