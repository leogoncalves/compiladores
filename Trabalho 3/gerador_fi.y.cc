%{
#include <string>
#include <iostream>
#include <map>
extern "C" int yylex();
using namespace std;

struct Atributos {
  string v;
};

#define YYSTYPE Atributos

void erro( string msg );
void Print( string st );

// protótipo para o analisador léxico (gerado pelo lex)
int yylex();
void yyerror( const char* );
int retorna( int tk );

int linha = 1;
int coluna = 1;

%}

%token NUM STR ID PRINT

%left '+' '-'
%left '*' '/'

%%

P : A ';' P
  | A ';'
  ;

A : ID { Print( $1.v ); } '=' E { Print( "=\n" ); }
  | PRINT E { Print( "print #\n" ); }
  ;
  
E : E '+' E { Print( "+" ); }
  | E '-' E { Print( "-" ); }
  | E '*' E { Print( "*" ); }
  | E '/' E { Print( "/" ); }
  | F
  ;
  
F : ID { Print( $1.v + " @" ); }
  | NUM { Print(  $1.v ); }
  | STR { Print(  $1.v ); }
  | '(' E ')'
  | ID '(' PARAM ')' { Print( $1.v + " #" ); }
  ;
  
PARAM : ARGs
      |
      ;
  
ARGs : E ',' ARGs
     | E
     ;
  
%%

#include "lex.yy.c"

map<int,string> nome_tokens = {
  { PRINT, "print" },
  { STR, "string" },
  { ID, "nome de identificador" },
  { NUM, "número" }
};

string nome_token( int token ) {
  if( nome_tokens.find( token ) != nome_tokens.end() )
    return nome_tokens[token];
  else {
    string r;
    
    r = token;
    return r;
  }
}

int retorna( int tk ) {  
  yylval.v = yytext; 
  coluna += strlen( yytext ); 

  return tk;
}

void yyerror( const char* msg ) {
  cout << endl << "Erro: " << msg << endl
       << "Perto de : '" << yylval.v << "'" <<endl;
  exit( 0 );
}

void Print( string st ) {
  cout << st << " ";
}

int main() {
  yyparse();
  
  cout << endl;
   
  return 0;
}