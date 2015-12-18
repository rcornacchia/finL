%{ open Ast %}


%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA /*COLON AT*/
/*%token POWER */
%token PLUS MINUS TIMES DIVIDE
/*%token MOD */
%token ASSIGN /* AASSIGN SASSIGN MASSIGN DASSIGN */
%token EQ GEQ GT LEQ LT
%token RETURN /*WHILE WHEN IF ELSE ELSEIF VOID NULL BREAK*/
/*%token AND OR NOT */
%token INTD STRINGD /* FLOATD PERCENT ARRAY STRING CURR STOCK ORDER PF */ FUNC
%token <int> INT
/* %token <float> FLOAT */
%token <string> STRING
/* %token <percent> FLOAT
%token <currency> FLOAT */
%token <string> VAR
%token EOF

/* %nonassoc ELSE */
%right ASSIGN /* AASSIGN SASSIGN MASSIGN DASSIGN */
%left EQ
%left GEQ GT LEQ LT
%left PLUS MINUS
%left TIMES DIVIDE /* MOD POWER */
/*%left OR*/
/*%left AND*/

%start /*expression*/ program
%type /*<Ast.expression> expression*/ <Ast.program> program


%%
program:
  lines EOF { $1 }

lines:
  /* nothing */ { { lines = [] } }
  | lines line { { lines = $2 :: $1.lines } }

line:
  statement { Stmt($1) }
  | fdecl { Fdecl($1) }

fdecl:
  FUNC /*type*/ VAR LPAREN params RPAREN
  LBRACE statement_list RBRACE SEMI
  { 
    {
      (*rtype = $2;*)
      name = $2;
      formals = $4;
      body = List.rev $7;
    }
  }

params:
  /* no parameters */ { [] }
  | param_list { List.rev $1 }

param_list:
  vdecl   { [$1] }
  | param_list COMMA vdecl { $3 :: $1 }

vdecl:
  INTD VAR { { dtype = Inttype; vname = $2 } }
  | STRINGD VAR { { dtype = Stringtype; vname = $2 } }

statement:
  expression SEMI { Expr($1) }
  | vdecl SEMI { Vdecl($1) }

statement_list:
  /* nothing */ { [] }
  | statement_list statement { $2 :: $1 }

expression:
  INT { Int($1) }
  | STRING  { String($1) }
  | VAR  { Var($1) }
  | expression PLUS expression  { Binop($1, Add, $3) }
  | expression MINUS  expression { Binop($1, Sub, $3) }
  | expression TIMES expression { Binop($1, Mult, $3 ) }
  | expression DIVIDE expression { Binop($1, Div, $3) }
  | expression EQ expression { Binop($1, Equal, $3) }
  | expression LT expression { Binop($1, Less, $3) }
  | expression LEQ expression { Binop($1, Leq, $3) }
  | expression GT expression { Binop($1, Greater, $3) }
  | expression GEQ expression { Binop($1, Geq, $3) }
  | VAR ASSIGN expression  { Assign($1, $3) }
  | VAR LPAREN args RPAREN { Call($1, $3) }
  | LPAREN expression RPAREN   { $2 }

args:
  /* no arguments */ { [] }
  | arg_list { List.rev $1 }

arg_list:
  expression { [$1] }
  | arg_list COMMA expression { $3 :: $1 }
