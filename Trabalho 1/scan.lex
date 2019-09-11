D [0-9]
L [A-Za-z_]
INI_COMMENT "/*"
STR_DELIMITER ["]

    /* Identificador, ex: a b _1 ab1 $tab _$5 */
ID ({L}|[$])([$]|{L}|{D})*

    /* Inteiro: 1 221 0*/
INT {D}+

    /* Float: 0.1 1.028 1.2E-4  0.2e+3 1e3 */
FLOAT {INT}("."{INT})?([Ee]("+"|"-")?{INT})?

    /* espaço em branco */
WS [ \t\n]

    /* for */
FOR ([Ff][Oo][r])

    /* if */
IF ([Ii][Ff])

    /* string sem quebra de linha: "hello, world", "Aspas internas com \" (contrabarra)", "ou com "" (duas aspas)" */
STRING ({STR_DELIMITER}(\\.|[^"\\])*{STR_DELIMITER})*

SIMPLE_COMMENT \/\/[^\n\r\t]*
COMPLEX_COMMENT (\/\*)(\*[^\/]|[^\*])*(\*\/) 
COMENTARIO ({SIMPLE_COMMENT}|{COMPLEX_COMMENT})

%%

{WS}	     { /* ignora espaço */ }    
{FOR}        { return _FOR; }
{IF}         { return _IF; }
{INT}	     { return _INT; }
{FLOAT}	     { return _FLOAT; }
{ID}	     { return _ID; }
{STRING}     { return _STRING; } 
">="	     { return _MAIG; }
"<="	     { return _MEIG; }
"=="         { return _IG; }
"!="         { return _DIF; }
{COMENTARIO} { return _COMENTARIO; } 
.            { return *yytext; }
%%
