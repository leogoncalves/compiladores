

DIGITO  [0-9]
LETRA   [A-Za-z_]
DOUBLE  {DIGITO}+("."{DIGITO}+)?
ID      {LETRA}({LETRA}|{DIGITO})*
STR 	\"([^\"\n]|(\\\")|\"\")+\"

%%

"\t"       { coluna += 4; }
" "        { coluna++; }
"\n"	   { linha++; coluna = 1; }

{DOUBLE}   { return retorna( NUM ); }
{STR}	   { return retorna( STR ); }

"print"    { return retorna( PRINT ); }

{ID}       { return retorna( ID ); }

.          { return retorna( *yytext ); }

%% 