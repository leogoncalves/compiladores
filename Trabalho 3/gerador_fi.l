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
{EMPTY_ARRAY}    { return retorna( EMPTY_ARRAY );}
{EMPTY_OBJECT}   { return retorna( EMPTY_OBJECT );}
.                { return retorna( *yytext ); }
%%