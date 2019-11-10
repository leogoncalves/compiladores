%{
#include <string>
#include <iostream>
#include <map>
#include <vector>

using namespace std;

extern "C" int yylex();

struct Atributos {
  vector<string> v;
};

#define YYSTYPE Atributos

void erro( string msg );
void Print( string st );
void Print( vector<string> st );


// protótipo para o analisador léxico (gerado pelo lex)
int yylex();
void yyerror( const char* );
int retorna( int tk );

int linha = 1;
int coluna = 1;

map<string,string> _INSTRUCTIONS = {
  { "GO_TO" , "#" },
  { "NEW_OBJECT" , "{}" },
  { "NEW_ARRAY" , "[]" },
  { "GET" , "@" },
  { "SET" , "=" },
  { "JUMP_TRUE" , "?" },
  { "LET" , "&" },
  { "GET_PROP" , "[@]" },
  { "SET_PROP" , "[=]" },
  { "CALL_FUNC" , "$" },
  { "POP" , "^" },  
  { "HALT" , "." },
  { "INSTRUCTION_PREFIX" , "_" },
  { "INSTRUCTION_SUFFIX" , ":" },
};


vector<string> concat(vector<string> a, vector<string> b) {
    vector<string> res;
    
    copy(a.begin(), a.end(), back_inserter(res));
    copy(b.begin(), b.end(), back_inserter(res));
    
    return res;
}

vector<string> operator +(vector<string> a, vector<string> b) {
    return concat(a, b);
}

vector<string> operator +( vector<string> a, string b) {
    return concat( a, vector<string>{b} );
}

vector<string> operator +( char a, vector<string> b) {
    return concat( vector<string>{ string(1, a) }, b );
}

vector<string> operator +( vector<string> a, char b) {
    return concat( a, vector<string>{ string(1,b) } );
}

string createLabels(string prefix) {
    static int n = 0;
    return prefix + "_" + to_string(++n) + ":";
}

vector<string> solveAddresses(vector<string> input) {
    map<string, int> label;
    vector<string> res;
    int i;

    for(i = 0; i < input.size(); i++) {
        if(input[i][0] == ':') {
            label[input[i].substr(1)] = res.size();
        } else {
            res.push_back(input[i]);
        }
    }

    for(i = 0; i < res.size(); i++) {
        if(label.count(res[i]) > 0) {
            res[i] = to_string(label[res[i]]);
        }
    }

    return res;
}

%}

%token NUM STR ID PRINT LET IF ELSE OBJECT ARRAY EQUALS

%right '='
%left  '>'
%left  '<'
%left  '+' '-'
%left  '*' '/'

%%

Program : P { Print(solveAddresses($1.v)); Print("."); }
        ;

P : CMD ';' P { $$.v = $$.v + $3.v; }
  | CMD ';' 
  ;

CMD : LET ATRIB { $$.v = $2.v; }
    | ATRIB { $$.v = $1.v; }
    ;

D : ID { $$.v = $1.v + '&'; }
  ;

ATRIB : ID '=' ARGS { $$.v = $1.v + '&' + $1.v + $3.v + '=' + '^'; }
      | ID '=' ATRIB { $$.v = $1.v + '&' + $3.v; }
      | D ',' ATRIB {$$.v = $1.v + $3.v;}
      | D
      ;

ARGS : ARG ',' ATRIB { $$.v = $1.v + $3.v;}
     ;

ARG : E { $$.v = $1.v; }
    ;

// E : E '+' E { $$.v = $1.v + $3.v + $2.v; }
//   | E '-' E { $$.v = $1.v + $3.v + $2.v; }
//   | E '*' E { $$.v = $1.v + $3.v + $2.v; }
//   | E '/' E { $$.v = $1.v + $3.v + $2.v; }
//   | E EQUALS E { $$.v = $1.v + $2.v + $3.v; }
//   | E '<' E { $$.v = $1.v + $3.v + $2.v; }
//   | E '>' E { $$.v = $1.v + $3.v + $2.v; }
//   | F
//   ;
  
E : E '+' E { $$.v = vector<string>{"+"}; }
  | E '-' E { $$.v = vector<string>{"-"}; }
  | E '*' E { $$.v = vector<string>{"*"}; }
  | E '/' E { $$.v = vector<string>{"/"}; }
  | E '<' E { $$.v = vector<string>{"<"}; }
  | E '>' E { $$.v = vector<string>{">"}; }
  | F
  ;

F : ID { $$.v = $1.v + "@"; }
  | NUM { $$.v = $1.v; }
  | STR { $$.v = $1.v; }
  | '(' E ')' 
  | '{' '}' { { $$.v = vector<string>{"{}"}; } }
  | '[' ']' { { $$.v = vector<string>{"[]"}; } }
  | FUNC '(' PARAMS ')' { $$.v = $1.v + '#'; }
  ;
  
FUNC : ID
     ;

PARAMS : PARAM ',' PARAMS
       | PARAM
       ;

PARAM : E
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
    vector<string> v{yytext};
    yylval.v = v; 
    coluna += strlen( yytext ); 


  return tk;
}

void yyerror( const char* msg ) {
  cout << endl << "Erro: " << msg << endl
       << "Perto de: '" << yylval.v.back() << "' na linha " << linha << " coluna " << coluna << endl;
  exit( 1 );
}

void Print(string str) {
    cout << str << " ";
}

void Print( vector<string> str ) {
    for(int i = 0; i < str.size(); i++) {
        cout << str[i] << " ";
    }
}

int main() {
  yyparse();
  
  cout << endl;
   
  return 0;
}