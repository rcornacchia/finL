%{ open Ast %}


%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA /*COLON*/
%token PLUS MINUS TIMES DIVIDE POWER MOD
%token ASSIGN AASSIGN SASSIGN MASSIGN DASSIGN
%token EQ GEQ GT LEQ LT
%token RETURN WHILE WHEN IF /*ELSE ELSEIF */ VOID /* NULL BREAK*/
%token AND OR NOT
%token BUY SELL PRINT
%token INTD STRINGD FLOATD /*PERCENT ARRAY CURR */ STOCK ORDER /*PF*/ FUNC OF
%token <string> TICK
%token <string> ACCESS
%token <int> INT
%token <float> FLOAT
%token <string> STRING
/* %token <percent> FLOAT
%token <currency> FLOAT */
%token <string> VAR
%token EOF

/* %nonassoc ELSE */
%right ASSIGN AASSIGN SASSIGN MASSIGN DASSIGN
%left AND OR
%left EQ
%left GEQ GT LEQ LT
%left PLUS MINUS
%left TIMES DIVIDE MOD
%left POWER

%start program
%type <Ast.program> program


%%
program:
  line_list EOF { { lines = List.rev $1 } }

line_list:
  /* nothing */ { [] }
  | line_list line { $2 :: $1 } 

line:
  statement { Stmt($1) }
  | fdecl { Fdecl($1) }

statement:
  expression SEMI { Expr($1) }
  | WHILE expression LBRACE statement_list RBRACE SEMI { While($2, $4) }
  | WHEN expression LBRACE statement_list RBRACE SEMI { When($2, $4) }
  | expression IF LBRACE statement_list RBRACE SEMI { If($1, $4) }
  | vdecl SEMI { Vdecl($1) }
  | BUY order SEMI { Buy($2) }
  | SELL order SEMI { Sell($2) }
  | PRINT expression SEMI { Print($2) }
  | RETURN expression SEMI { Ret($2) } /* VOID TYPES */

order:
  VAR { Var($1) }
  | INT OF stock { Order($1, $3) }

stock:
  VAR { Var($1) }
  | TICK { Stock($1) }

expression:
  INT { Int($1) }
  | STRING  { String($1) }
  | FLOAT { Float($1) }
  | TICK { Stock($1) }
  | VAR  { Var($1) }
  | INT OF stock { Order($1, $3) }
  | MINUS expression { Unop(Neg, $2) }
  | NOT LPAREN expression RPAREN { Unop(Not, $3) }
  | stock ACCESS { Access($1, $2) }
  | expression PLUS expression  { Binop($1, Add, $3) }
  | expression MINUS expression  { Binop($1, Sub, $3) }
  | expression TIMES expression { Binop($1, Mult, $3 ) }
  | expression DIVIDE expression { Binop($1, Div, $3) }
  | expression EQ expression { Binop($1, Equal, $3) }
  | expression LT expression { Binop($1, Less, $3) }
  | expression LEQ expression { Binop($1, Leq, $3) }
  | expression GT expression { Binop($1, Greater, $3) }
  | expression GEQ expression { Binop($1, Geq, $3) }
  | expression MOD expression { Binop($1, Mod, $3) }
  | expression POWER expression { Binop($1, Pow, $3) }
  | expression AND expression { Binop($1, And, $3) }
  | expression OR expression { Binop($1, Or, $3) }
  | VAR ASSIGN expression  { Assign($1, $3) }
  | VAR AASSIGN expression { Aassign($1, $3) }
  | VAR SASSIGN expression { Sassign($1, $3) }
  | VAR MASSIGN expression { Massign($1, $3) }
  | VAR DASSIGN expression { Dassign($1, $3) }
  | VAR LPAREN args RPAREN { Call($1, $3) }
  | LPAREN expression RPAREN { $2 }

args:
  /* no arguments */ { [] }
  | arg_list { List.rev $1 }

arg_list:
  expression { [$1] }
  | arg_list COMMA expression { $3 :: $1 }

vdecl:
  dtype VAR { { dtype = $1; vname = $2 } }

vdtype:
  VOID { Voidtype }
  | dtype { $1 }

dtype:
  INTD { Inttype }
  | STRINGD { Stringtype }
  | FLOATD { Floattype }
  | STOCK { Stocktype }
  | ORDER  { Ordertype }

fdecl:
  FUNC vdtype VAR LPAREN params RPAREN
  LBRACE statement_list RBRACE SEMI
  { 
    {
      rtype = $2;
      name = $3;
      formals = $5;
      body = List.rev $8;
    }
  }

params:
  /* no parameters */ { [] }
  | param_list { List.rev $1 }

param_list:
  vdecl   { [$1] }
  | param_list COMMA vdecl { $3 :: $1 }

statement_list:
  /* nothing */ { [] }
  | statement_list statement { $2 :: $1 }