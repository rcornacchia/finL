%{ open Ast
%}


%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA COLON AT
(*%token POWER *)
%token PLUS MINUS TIMES DIVIDE
(*%token MOD *)
%token ASSIGN (* AASSIGN SASSIGN MASSIGN DASSIGN
%token EQ GEQ GT LEQ LT *)
%token RETURN WHILE WHEN IF ELSE ELSEIF VOID NULL BREAK
(*%token AND OR NOT *)
%token INTD FLOATD PERCENT ARRAY STRING CURR STOCK ORDER PF FUNC
%token <int> INT
(* %token <float> FLOAT *)
%token <string> STR
(* %token <percent> FLOAT
%token <currency> FLOAT *)
%token EOF

(* %nonassoc ELSE *)
%right ASSIGN (* AASSIGN SASSIGN MASSIGN DASSIGN *)
/*%left EQ*/
/*%left GEQ GT LEQ LT*/
%left PLUS MINUS
/*%left TIMES DIVIDE MOD*/
/*%left OR*/
/*%left AND*/

%start program
%type <Ast.program> program


%%
program:
	/* nothing */				{ [] }
	| program vdecl 			{ ($2 :: fst $1), snd $1 }
  | program fdecl     {fst $1, ($2 :: snd $1) }

fdecl:
  FUNC type VAR LPAREN args RPAREN COLON
  LBRACE statement_list RBRACE
  {
    { fname = $3;
      formals = $5;
      funcBody = List.rev $9;
    }
  }

args:
  { [] }
  | arg_list {List.rev $1}

arg_list:
  VAR   { [$1] }
  | arg_list COMMA VAR   {$3 :: $1}

vdecl_list:
  { [] }
  | vdecl_list vdecl  { $2 :: $1}

vdecl:
  INT VAR SEMI  {$2}
  | STRING VAR SEMI {$2}
  (* TODO dont forget other types!!! *)

statement_list:
  { [] }
  | statement_list statement  {$2 :: $1}

statement:
  expression SEMI

expression:
 INT  {Int($1)}
 | VAR  {Var($1)}
 | expression PLUS expression  { Binop($1, Add, $3) }
 | VAR ASSIGN expression  { Assign($1, $3) }
 | VAR LPAREN expression RPAREN { Call($1, $3)}
 | LPAREN expression RPAREN   { $2 }
