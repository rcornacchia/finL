open Ast

type sfunc_decl = {
  srtype : Ast.data_type;
  sname : string;
  sformals : Ast.var_decl list;
  sbody : Ast.statement list;
  builtin : bool;
}

type sprogram = { 
    sfunc_decls : sfunc_decl list;
    statements : Ast.statement list;
}

let string_of_sfdecl (sfdecl: sfunc_decl) =
  "sname{" ^ 
  sfdecl.sname ^ 
  "} srtype{" ^
  Ast.string_of_data_type sfdecl.srtype ^
  "} sformals{" ^ 
  String.concat ", " (List.map Ast.string_of_vdecl sfdecl.sformals) ^ 
  "} builtin {" ^
  string_of_bool sfdecl.builtin ^
  "}\nsbody{\nstatement{" ^
  String.concat "}\nstatement{" (List.map Ast.string_of_statement sfdecl.sbody) ^
  "}\n}"

let string_of_sprogram (sprog: sprogram) =
	"sprogram{\nsfunc_decls{\nsfunc_decl{\n" ^ 
  String.concat "\n}\nsfunc_decl{\n" (List.map string_of_sfdecl sprog.sfunc_decls) ^ 
  "\n}\n}\nstatements{\nstatement{" ^
  String.concat "}\nstatement{" (List.map Ast.string_of_statement sprog.statements) ^
  "}\n}\n}\n"