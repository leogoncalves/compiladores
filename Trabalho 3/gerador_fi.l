D  [0-9]
L   [A-Za-z_]
DOUBLE  {D}+("."{D}+)?
LET     let
PRINT   ([Pp][rint])
IF      ([Ii][Ff])
ELSE    ([Ee][Ll][Ss][Ee])
WHILE   ([Ww][hile])
FOR     ([Ff][Oo][r])
ID      {L}({L}|{D})*
STR 	(\"([^\"\n]|(\\\")|\"\")+\"|\'([^\'\n]|(\\\')|\'\')+\')
EMPTY_ARRAY \[\]
EMPTY_OBJECT   \{\}
SIMPLE_COMMENT \/\/[^\n\r\t]*
COMPLEX_COMMENT (\/\*)(\*[^\/]|[^\*])*(\*\/) 
COMMENT ({SIMPLE_COMMENT}|{COMPLEX_COMMENT})
%%
"\t"             { column += 4; }
" "              { column++; }
"\n"	         { line++; column = 1; }
{DOUBLE}         { return retorna( NUM ); }
{STR}	         { return retorna( STR ); }
{PRINT}          { return retorna( PRINT ); }
{LET}            { return retorna( LET ); }
{IF}             { return retorna( IF ); }
{ELSE}           { return retorna( ELSE ); }
{WHILE}          { return retorna( WHILE ); }
{FOR}            { return retorna( FOR   ); }
{ID}             { return retorna( ID ); }
">" 	         { return retorna( GREATER_THAN ); }
"<"	             { return retorna( LESS_THAN ); }
">="	         { return retorna( GREATER_THAN_OR_EQUAL ); }
"<="	         { return retorna( LESS_THAN_OR_EQUAL ); }
"=="             { return retorna( EQUAL_TO ); }
"==="            { return retorna( EQUAL_VALUE_AND_TYPE ); }
"!="             { return retorna( NOT_EQUAL_TO ); }
"!=="            { return retorna( NOT_EQUAL_VALUE_OR_TYPE ); }
{EMPTY_ARRAY}    { return retorna( EMPTY_ARRAY );}
{EMPTY_OBJECT}   { return retorna( EMPTY_OBJECT );}
{COMMENT}        { return retorna( COMMENT ); } 
.                { return retorna( *yytext ); }
%%