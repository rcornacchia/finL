{ open Parser }

let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let ticker = '@'letter+
let variable = letter(letter|digit|'_')*
let access = letter(letter|digit)*

rule token = parse
	[' ' '\t' '\r' '\n']     { token lexbuf }
	| '#'                    { comment lexbuf }
	| '('                    { LPAREN }
	| ')'                    { RPAREN }
	| '{'                    { LBRACE }
	| '}'                    { RBRACE }
	(*| ':'                    { COLON }*)
	| ';'                    { SEMI }
	| ','                    { COMMA }
	| '+'                    { PLUS }
	| '-'                    { MINUS }
	| '*'                    { TIMES }
	| '/'                    { DIVIDE }
	| '%'                    { MOD }
	| "**"                   { POWER }
	| '<'                    { LT }
	| "<="                   { LEQ }
	| '>'                    { GT }
	| ">="                   { GEQ }
	| '='                    { EQ }
	| "<<"                   { ASSIGN }
	| "+<<"                  { AASSIGN }
	| "-<<"                  { SASSIGN }
	| "*<<"                  { MASSIGN }
	| "/<<"                  { DASSIGN }
	| "and"                  { AND }
	| "or"                   { OR }
	| "not"                  { NOT }
	| "of"					 { OF }
	| "buy"					 { BUY }
	| "sell"				 { SELL }
	| "print"				 { PRINT }
	| '?'                    { IF }
	(*| "??"                   { ELSEIF }*)
	| '!'                    { ELSE }
	| "while"                { WHILE }
	| "when"                 { WHEN }
	(*| "break"                { BREAK }*)
	| "int"                  { INTD }
	| "float"                { FLOATD }
	(*| "percent"              { PERCENT }
	| "null"                 { NULL }
	| "array"                { ARRAY }*)
	| "string"               { STRINGD }
	(*| "currency"             { CURR }*)
	| "stock"                { STOCK }
	| "order"                { ORDER }
	| "portfolio"            { PF }
	| "function"             { FUNC }
	| "return"               { RETURN }
	| "void"                 { VOID }
	| ticker as t		 	 { TICK(t) }
	| variable as var   	 { VAR(var) }
	| '['access*']' as a     { ACCESS(a) }
	| digit+ as i            { INT(int_of_string i) }
	| digit*'.'digit+ as flt { FLOAT(float_of_string flt) }
	| '"'('\\'_|[^'"'])*'"' as str   { STRING(str) }
	| eof                  	 { EOF }

and comment = parse
	'\n' { token lexbuf }
	| eof { EOF }
	| _  { comment lexbuf }