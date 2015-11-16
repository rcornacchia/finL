
open Ast


let compile (prog: Ast.program) =
	"public class finl{\n" ^

  String.concat "\n" (List.map j_layout prog.syms.layouts) ^
