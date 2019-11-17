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

#define GO_TO "#"
#define GET "@"
#define SET "="
#define JUMP_TRUE "?"
#define _LET "&"
#define GET_PROP "[@]"
#define SET_PROP "[=]"
#define CALL_FUNC "$"
#define POP "^"
#define HALT "."

void erro( string msg );
void Print( string st );
void Print( vector<string> st );


int yylex();
void yyerror( const char* );
int retorna( int tk );

int line = 1;
int column = 1;

string INI_IF;
string END_IF;
string END_ELSE;

string INI_WHILE;
string INI_WHILE_CLOSURE;
string END_WHILE;

vector<string> Variables;
map<string, int> VariableDeclaration;


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

vector<string> operator +( string a, vector<string> b) {
    return concat( vector<string>{a}, b );
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

void nonVariable(string variable) {
    int nonVariable = VariableDeclaration.count(variable); 
    if(nonVariable == 0) {
        cerr << "Erro: a variável '" << variable << "' não foi declarada." << endl;
        exit(1);
    }
}

void duplicateVariable(string variable) {
    int duplicates = VariableDeclaration.count(variable);
    if(duplicates) {
        cerr << "Erro: a variável '" << variable << "' já foi declarada na linha " << VariableDeclaration[variable] << HALT << endl;
        exit(1);
    } else {
        VariableDeclaration[variable] = line;
    }

}

void CREATE_IF_LABELS(){
    INI_IF = createLabels("ini_if"); 
    END_IF = createLabels("end_if"); 
    END_ELSE = createLabels("end_else");
}

void CREATE_WHILE_LABELS(){
    INI_WHILE = createLabels("ini_while");
    INI_WHILE_CLOSURE = createLabels("ini_while_closure");
    END_WHILE = createLabels("end_while");
}

%}

%token NUM STR ID PRINT LET IF ELSE FOR WHILE EMPTY_ARRAY EMPTY_OBJECT
%token EQUAL_TO NOT_EQUAL_TO NOT_EQUAL_VALUE_OR_TYPE EQUAL_VALUE_AND_TYPE 
%token GREATER_THAN GREATER_THAN_OR_EQUAL LESS_THAN LESS_THAN_OR_EQUAL
%token COMMENT

%nonassoc GREATER_THAN '>' GREATER_THAN_OR_EQUAL LESS_THAN_OR_EQUAL
%right '='
%left '.'
%left  '+' '-'
%left  '*' '/'
%left '%'

%%

Program : P { Print(solveAddresses($1.v)); Print(HALT); }
        ;

P : CMD ';' P    { $$.v = $1.v + $3.v;}
  | CMD ';'
  | CMD_IF       { $$.v = $1.v; }
  | CMD_WHILE    { $$.v = $1.v; }
  ;

CMD_IF  : IF COND_EXPRESSION IF_CLOSURE CMD_ELSE { 
            CREATE_IF_LABELS();
            $$.v = $2.v + INI_IF + JUMP_TRUE + END_IF + GO_TO + (":" + INI_IF) + $3.v + (":" + END_IF) + $4.v; 
        }
        | IF COND_EXPRESSION CMD ';' P {
            CREATE_IF_LABELS();
            $$.v = $2.v + INI_IF + JUMP_TRUE + END_IF + GO_TO + (":" + INI_IF) + $3.v + (":" + END_IF) + $5.v;
        }
        | IF COND_EXPRESSION CMD ';' {
            CREATE_IF_LABELS();
            $$.v = $2.v + INI_IF + JUMP_TRUE + END_IF + GO_TO + (":" + INI_IF) + $3.v + (":" + END_IF);
        }
        ;

IF_CLOSURE : '{' P '}' { $$.v = $2.v + END_ELSE + GO_TO; }
           | CMD ';'   { $$.v = $1.v + END_ELSE + GO_TO; }
           ;

CMD_ELSE : ELSE CLOSURE   { $$.v = $2.v + (":" + END_ELSE); }
         | ELSE CMD ';'   { $$.v = $2.v + (":" + END_ELSE); }
         | ELSE CMD ';' P { $$.v = $2.v + (":" + END_ELSE) + $4.v; }
         | ELSE CMD_IF    { $$.v = $2.v + (":" + END_ELSE); }
         ;

CMD_WHILE : WHILE COND_EXPRESSION WHILE_CLOSURE P {
            CREATE_WHILE_LABELS();
            $$.v = (":" + INI_WHILE) + $2.v + INI_WHILE_CLOSURE + JUMP_TRUE + END_WHILE + GO_TO + (":" + INI_WHILE_CLOSURE) + $3.v + INI_WHILE + GO_TO + (":" + END_WHILE) + $4.v;
          }
          | WHILE COND_EXPRESSION WHILE_CLOSURE {
            CREATE_WHILE_LABELS();
            $$.v = (":" + INI_WHILE) + $2.v + INI_WHILE_CLOSURE + JUMP_TRUE + END_WHILE + GO_TO + (":" + INI_WHILE_CLOSURE) + $3.v + INI_WHILE + GO_TO + (":" + END_WHILE);
          }
          ;

WHILE_CLOSURE : '{' P '}' { $$.v = $2.v; }
              | CMD ';'   { $$.v = $1.v; }
              ;

COND_EXPRESSION : '(' E LESS_THAN E ')'     { $$.v = $2.v + $4.v + $3.v;  }
                | '(' E GREATER_THAN E ')'  { $$.v = $2.v + $4.v + $3.v;  }
                | '(' E EQUAL_TO E ')' { $$.v = $2.v + $4.v + $3.v; }
                ;

CLOSURE : '{' P '}' { $$.v = $2.v; }

CMD : CMD_LET { $$.v = $1.v; }
    | ATRIB   { $$.v = $1.v + POP; }
    ;

CMD_LET : LET ARGS  { $$.v = $2.v; }
        ;

ARGS : ATRIB_VALUE ',' ARGS { $$.v = $1.v + $3.v; }
     | ATRIB_VALUE          { $$.v = $1.v; }
     ;

ATRIB_VALUE : ID       { duplicateVariable($1.v[0]); $$.v = $1.v + _LET ; }
            | ID '=' E { duplicateVariable($1.v[0]); $$.v = $1.v + _LET + $1.v + $3.v + SET + POP; }
            ;

ATRIB : ID '=' ATRIB      { nonVariable($1.v[0]); $$.v = $1.v + $3.v + SET; }
      | ID '=' E          { nonVariable($1.v[0]); $$.v = $1.v + $3.v + SET; }
      | OBJECT '=' E      { $$.v = $1.v + $3.v + SET_PROP; }
      | OBJECT '=' ATRIB  { $$.v = $1.v + $3.v + SET_PROP; }
      ;

OBJECT : ID '.' ID              { $$.v = $1.v + GET + $3.v; }
       | ID '.' ID '[' E ']'    { $$.v = $1.v + GET + $3.v + GET_PROP + $5.v; }
       | ID '[' E ']'           { $$.v = $1.v + GET + $3.v; }
       | ID '[' ATRIB ']'       { $$.v = $1.v + GET + $3.v; }
       | ID '[' E ']' '[' E ']' { $$.v = $1.v + GET + $3.v + GET_PROP + $6.v; }
       ;

E : E '+' E   { $$.v = $1.v + $3.v + "+"; }
  | E '-' E   { $$.v = $1.v + $3.v + "-"; }
  | E '*' E   { $$.v = $1.v + $3.v + "*"; }
  | E '/' E   { $$.v = $1.v + $3.v + "/"; }
  | E GREATER_THAN E   { $$.v = $1.v + $3.v + "<"; } 
  | E '>' E   { $$.v = $1.v + $3.v + ">"; }
  | F
  ;
  
F : ID                      { $$.v = $1.v +  GET; }
  | '-' NUM                 { $$.v = "0" + $2.v + "-"; }
  | NUM                     { $$.v = $1.v; }
  | STR                     { $$.v = $1.v; }
  | ID '.' ID               { $$.v = $1.v + GET + $3.v + GET_PROP; }
  | ID '[' E ']' '[' E ']'  { $$.v = $1.v + GET + $3.v + GET_PROP + $6.v + GET_PROP; }
  | '(' E ')'               { $$.v = $2.v; }
  | FUNCTION '(' PARAMS ')' { Print( $1.v + GO_TO ); }
  | EMPTY_ARRAY
  | EMPTY_OBJECT
  ;

FUNCTION : ID
         ;

PARAMS : PARAMS ',' PARAMS
       | PARAM

PARAM : E
      ;

%%

#include "lex.yy.c"

map<int,string> _TOKENS = {
  { PRINT, "print" },
  { STR, "string" },
  { ID, "nome de identificador" },
  { NUM, "número" }
};

string nome_token( int token ) {
  if( _TOKENS.find( token ) != _TOKENS.end() )
    return _TOKENS[token];
  else {
    string r;
    
    r = token;
    return r;
  }
}

int retorna( int tk ) {  
    vector<string> v{yytext};
    yylval.v = v; 
    column += strlen( yytext ); 


  return tk;
}

void yyerror( const char* msg ) {
  cout << endl << "Erro: " << msg << endl
       << "Perto de: '" << yylval.v.back() << "' na linha " << line << " coluna " << column << endl;
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
  
  cout <<  endl ;
   
  return 0;
}