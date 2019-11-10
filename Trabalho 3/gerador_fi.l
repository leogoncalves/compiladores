DIGITO  [0-9]
LETRA   [A-Za-z_]
DOUBLE  {DIGITO}+("."{DIGITO}+)?
LET     let
IF      if
ELSE    else
ID      {LETRA}({LETRA}|{DIGITO})*
STR 	(\"([^\"\n]|(\\\")|\"\")+\"|\'([^\'\n]|(\\\')|\'\')+\')
ARRAY   \[\]
OBJECT  \{\}

%%

"\t"       { coluna += 4; }
" "        { coluna++; }
"\n"	   { linha++; coluna = 1; }

{DOUBLE}   { return retorna( NUM ); }
{STR}	   { return retorna( STR ); }

"print"    { return retorna( PRINT ); }

{LET}      {return retorna(LET);}
"if"       { return retorna( IF ); }
"else"     { return retorna( ELSE ); }
"=="       { return retorna( EQUALS ); }
{ID}       { return retorna( ID ); }

{ARRAY}    {return retorna (ARRAY);}
{OBJECT}   {return retorna (OBJECT);}

.          { return retorna( *yytext ); }

%% 