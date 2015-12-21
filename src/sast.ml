open Ast

type expr = 
  Sint of int
  | Sstring of string
  | Sfloat of float
  | Sstock of string
  | Sorder of int * sexpression
  | Svar of string
  | Sunop of Ast.unop * sexpression
  | Sbinop of sexpression * Ast.binop * sexpression
  | Saccess_assign of string * saccess_expression
  | Sassign of string * sexpression
  | Saassign of string * sexpression
  | Ssassign of string * sexpression
  | Smassign of string * sexpression
  | Sdassign of string * sexpression
  | Scall of string * sexpression list
  | Snoexpr
and saccess_expression =
  Saccess of sexpression * string
  | Sabinop of saccess_expression * binop * saccess_expression
and expr_type =
  Nonaccess_expr of expr
  | Access_expr of saccess_expression
and sexpression = {
  sexpr : expr_type;
  sdtype : Ast.data_type;
}

type sstatement =
  Sexpr of sexpression
  | Sif of sexpression * sstatement list
  | Swhile of sexpression * sstatement list
  | Swhen of sexpression * sstatement list
  | Svdecl of Ast.var_decl
  | Sret of sexpression
  | Sbuy of sexpression
  | Ssell of sexpression
  | Sprint of sexpression

type sfunc_decl = {
  srtype : Ast.data_type;
  sname : string;
  sformals : Ast.var_decl list;
  sbody : sstatement list;
}

type sprogram = { 
    sfunc_decls : sfunc_decl list;
    sstatements : sstatement list;
}

let rec string_of_sexpression (sexpr: sexpression) = 
  let expr = match sexpr.sexpr with
              Nonaccess_expr(ne) -> string_of_nonaccess ne
              | Access_expr(ae) -> string_of_access_expr ae
  in expr ^ " -> " ^ Ast.string_of_data_type sexpr.sdtype
and string_of_nonaccess = function
  Sint(i) -> "Sint(" ^ string_of_int i ^ ")"
  | Sstring(s) -> "Sstring(" ^ s ^ ")"
  | Sfloat(f) -> "Sfloat(" ^ string_of_float f ^ ")"
  | Sstock (stk) -> "Sstock(" ^ stk ^ ")"
  | Sorder (i, ord) -> "Sorder(" ^ string_of_int i ^ " of " ^ string_of_sexpression ord ^ ")"
  | Svar(v) -> "Svar(" ^ v ^ ")"
  | Sunop(op, se) -> "Sunop(" ^ Ast.string_of_unop op ^ " " ^ string_of_sexpression se ^ ")"
  | Sbinop(e1, o, e2) -> "Sbinop(" ^ string_of_sexpression e1 ^ " " ^ Ast.string_of_binop o ^ " " ^ string_of_sexpression e2 ^ ")"
  | Sassign(a, e) -> "Sassign(" ^ a ^ " = " ^ string_of_sexpression e ^ ")"
  | Saccess_assign(s, ae) -> "Saccess_assign(" ^ s ^ " = " ^ string_of_access_expr ae ^ ")"
  | Saassign(aa, e) -> "Saassign(" ^ aa ^ " = " ^ string_of_sexpression e ^ ")"
  | Ssassign(sa, e) -> "Ssassign(" ^ sa ^ " = " ^ string_of_sexpression e ^ ")"
  | Smassign(ma, e) -> "Smassign(" ^ ma ^ " = " ^ string_of_sexpression e ^ ")"
  | Sdassign(da, e) -> "Sdassign(" ^ da ^ " = " ^ string_of_sexpression e ^ ")"
  | Scall(c, el) -> c ^ "(" ^ String.concat ", " (List.map string_of_sexpression el) ^ ")"
  | Snoexpr -> ""
and string_of_access_expr = function
  Saccess(e, s) -> "Saccess(" ^ string_of_sexpression e ^ " -> " ^ s ^ ")"
  | Sabinop(ae1, op, ae2) -> string_of_access_expr ae1 ^ Ast.string_of_binop op ^ string_of_access_expr ae2

let rec string_of_sstatement = function
  Sexpr(e) -> "sexpression{" ^ string_of_sexpression e ^ "}"
  | Sif(sexpr, ssl) -> "sif{ sstatement{" ^ String.concat "} sstatement{" (List.map string_of_sstatement ssl) ^ "}}"
  | Swhile(sexpr, ssl) -> "swhile{ sstatement{" ^ String.concat "} sstatement{" (List.map string_of_sstatement ssl) ^ "}}"
  | Swhen(sexpr, ssl) -> "swhen{ sstatement{" ^ String.concat "} sstatement{" (List.map string_of_sstatement ssl) ^ "}}"
  | Svdecl(v) -> Ast.string_of_vdecl v
  | Sret(r) -> "sreturn{ sexpression{" ^ string_of_sexpression r ^ "}}"
  | Sbuy(b) -> "sbuy{ sexpression{" ^ string_of_sexpression b ^ "}}"
  | Ssell(s) -> "ssell{ sexpression{" ^ string_of_sexpression s ^ "}}"
  | Sprint(p) -> "sprint{ sexpression{" ^ string_of_sexpression p ^ "}}"

let string_of_sfdecl (sfdecl: sfunc_decl) =
  "sname{" ^ 
  sfdecl.sname ^ 
  "} srtype{" ^
  Ast.string_of_data_type sfdecl.srtype ^
  "} sformals{" ^ 
  String.concat ", " (List.map Ast.string_of_vdecl sfdecl.sformals) ^ 
  "}\nsbody{\nsstatement{" ^
  String.concat "}\nsstatement{" (List.map string_of_sstatement sfdecl.sbody) ^
  "}\n}"

let string_of_sprogram (sprog: sprogram) =
	"sprogram{\nsfunc_decls{\nsfunc_decl{\n" ^ 
  String.concat "\n}\nsfunc_decl{\n" (List.map string_of_sfdecl sprog.sfunc_decls) ^ 
  "\n}\n}\nsstatements{\nsstatement{" ^
  String.concat "}\nsstatement{" (List.map string_of_sstatement sprog.sstatements) ^
  "}\n}\n}\n"