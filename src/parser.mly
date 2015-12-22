%{ open Ast %}


%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA
%token PLUS MINUS TIMES DIVIDE POWER MOD
%token ASSIGN AASSIGN SASSIGN MASSIGN DASSIGN
%token EQ GEQ GT LEQ LT
%token RETURN WHILE WHEN IF ELSE VOID
%token AND OR NOT
%token BUY SELL PRINT
%token INTD STRINGD FLOATD /*ARRAY*/ STOCK ORDER PF FUNC OF
%token <string> TICK
%token <string> ACCESS
%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token <string> VAR
%token EOF

%nonassoc NOELSE
%nonassoc ELSE
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
  | WHEN access_expression LBRACE statement_list RBRACE SEMI { When($2, $4) }
  | expression IF LBRACE statement_list RBRACE %prec NOELSE SEMI { If($1, $4, []) }
  | expression IF LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE SEMI { If($1, $4, $8) }
  | vdecl SEMI { Vdecl($1) }
  | BUY order SEMI { Buy($2) }
  | SELL order SEMI { Sell($2) }
  | PRINT expression_option SEMI { Print($2) }
  | RETURN expression_option SEMI { Ret($2) }
  | PF STRING SEMI { Portfolio($2) }

access_expression:
  access EQ access { ($1, Equal, $3) }
  | access EQ number { ($1, Equal, $3) }
  | number EQ access { ($1, Equal, $3) }
  | access LT access { ($1, Less, $3) }
  | access LT number { ($1, Less, $3) }
  | number LT access { ($1, Less, $3) }
  | access LEQ access { ($1, Leq, $3) }
  | access LEQ number { ($1, Leq, $3) }
  | number LEQ access { ($1, Leq, $3) }
  | access GT access { ($1, Greater, $3) }
  | access GT number { ($1, Greater, $3) }
  | number GT access { ($1, Greater, $3) }
  | access GEQ access { ($1, Geq, $3) }
  | access GEQ number { ($1, Geq, $3) }
  | number GEQ access { ($1, Geq, $3) }

number:
  INT { Int($1) }
  | FLOAT { Float($1) }

access:
  stock ACCESS { Access($1, $2) }

order:
  VAR { Var($1) }
  | INT OF stock { Order($1, $3) }

stock:
  VAR { Var($1) }
  | TICK { Stock($1) }

expression_option:
  /* nothing */ { Noexpr }
  | expression { $1 }

expression:
  number { $1 }
  | STRING  { String($1) }
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