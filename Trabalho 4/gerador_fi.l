D  [0-9]
L   [A-Za-z_]
DOUBLE  {D}+("."{D}+)?
LET     let
PRINT   ([Pp][rint])
IF      ([Ii][Ff])
ELSE    ([Ee][Ll][Ss][Ee])
WHILE   while
FUNCTION   function
RETURN return
FOR     for
ID      {L}({L}|{D})*
STR 	(\"([^\"\n]|(\\\")|\"\")+\"|\'([^\'\n]|(\\\')|\'\')+\')
NEW_ARRAY \[\]
NEW_OBJECT   \{\}
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
{FUNCTION}       { return retorna( FUNCTION   ); }
{RETURN}         { return retorna( RETURN   ); }
{ID}             { return retorna( ID ); }
"%" 	         { return retorna( MOD_OPERATOR ); }
">" 	         { return retorna( GREATER_THAN ); }
"<"	             { return retorna( LESS_THAN ); }
">="	         { return retorna( GREATER_THAN_OR_EQUAL ); }
"<="	         { return retorna( LESS_THAN_OR_EQUAL ); }
"=="             { return retorna( EQUAL_TO ); }
"==="            { return retorna( EQUAL_VALUE_AND_TYPE ); }
"!="             { return retorna( NOT_EQUAL_TO ); }
"!=="            { return retorna( NOT_EQUAL_VALUE_OR_TYPE ); }
"asm{".*"}"      {  
                    string lexema = trim( yytext + 3, "{}" ); 
                    yylval.v = tokeniza( lexema );
                    coluna += strlen( yytext ); 
                    return ASM; 
                 }
{NEW_ARRAY}      { return retorna( NEW_ARRAY );}
{NEW_OBJECT}     { return retorna( NEW_OBJECT );}
{COMMENT}        { return retorna( COMMENT ); } 
.                { return retorna( *yytext ); }
%%