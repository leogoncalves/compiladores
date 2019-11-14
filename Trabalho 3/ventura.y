%{
#include <string>
#include <vector>
#include <iostream>
#include <map>

using namespace std;

string begin_if;
string end_if;
string end_else;
string begin_while;
string begin_while_block;
string end_while;

vector<string> variables;
map<string,int> variables_declaraction_line;

struct Atributos {
    vector<string> v;
};

#define YYSTYPE Atributos

void erro( string msg );
void Print( string st );
void Print( vector<string> st );
void chk_duplicate_declaration(string var);
void chk_atribuition_to_var(string var);

// protótipo para o analisador léxico (gerado pelo lex)
extern "C" int yylex();
void yyerror( const char* );
int retorna( int tk );

int linha = 1;
int coluna = 1;

string gera_label( string prefixo );
vector<string> resolve_enderecos( vector<string> entrada );

vector<string> concatena( vector<string> a, vector<string> b ) {
  a.insert( a.end(), b.begin(), b.end() );
  return a;
}

vector<string> operator + ( vector<string> a, vector<string> b ) {
    return concatena( a, b );
}

vector<string> operator + ( string a, vector<string> b) {
    return concatena( vector<string>{a}, b );
}

vector<string> operator + ( vector<string> a, string b) {
    return concatena( a, vector<string>{b} );
}

vector<string> operator + ( char a, vector<string> b) {
    return concatena( vector<string>{ string(1, a) }, b );
}

vector<string> operator + ( vector<string> a, char b) {
    return concatena( a, vector<string>{ string(1,b) } );
}

%}

%token NUM STR ID PRINT LET IF ELSE WHILE FOR
%right '='
%left ','
%left '+' '-'
%left '*' '/'

%%

START : P { Print(resolve_enderecos($1.v)); Print("."); }
      ;

P : CMD ';' P   { $$.v = $1.v + $3.v;}
  | CMD ';'
  | CMD_IF      { $$.v = $1.v; }
  | CMD_WHILE   { $$.v = $1.v; }
  | CMD_FOR     { $$.v = $1.v; }
  ;

CMD_FOR : FOR '(' CMD ';' BOOL ';' CMD ')' BLOCO P  {
    string cond_for = gera_label("cond_for"), _cond_for = ':' + cond_for;
    string begin_for_block = gera_label("begin_for_block"), _begin_for_block = ':' + begin_for_block;
    string end_for = gera_label("end_for"), _end_for = ':' + end_for;
    $$.v = $3.v + _cond_for + $5.v + begin_for_block + '?' + end_for + '#' + _begin_for_block + $9.v + $7.v + cond_for + '#' + _end_for + $10.v; }

        | FOR '(' CMD ';' BOOL ';' CMD ')' BLOCO    {
    string cond_for = gera_label("cond_for"), _cond_for = ':' + cond_for;
    string begin_for_block = gera_label("begin_for_block"), _begin_for_block = ':' + begin_for_block;
    string end_for = gera_label("end_for"), _end_for = ':' + end_for;
    $$.v = $3.v + _cond_for + $5.v + begin_for_block + '?' + end_for + '#' + _begin_for_block + $9.v + $7.v + cond_for + '#' + _end_for;
}


CMD_WHILE : WHILE COND BLOCO_WHILE P    {
                                            begin_while = gera_label("begin_while");
                                            begin_while_block = gera_label("begin_while_block");
                                            end_while = gera_label("end_while");
                                            $$.v = (':' + begin_while) + $2.v + begin_while_block + '?' + end_while + '#' + (':' + begin_while_block) + $3.v + begin_while + '#' + (':' + end_while) + $4.v;
                                        }
          | WHILE COND BLOCO_WHILE  {
                                        begin_while = gera_label("begin_while");
                                        begin_while_block = gera_label("begin_while_block");
                                        end_while = gera_label("end_while");
                                        $$.v = (':' + begin_while) + $2.v + begin_while_block + '?' + end_while + '#' + (':' + begin_while_block) + $3.v + begin_while + '#'  + (':' + end_while);
                                    }
          ;

BLOCO_WHILE : '{' P '}' { $$.v = $2.v; }
            | CMD ';'   { $$.v = $1.v; }
            ;

CMD_IF : IF COND BLOCO_IF CMD_ELSE     {
                                        begin_if = gera_label("begin_if");
                                        end_if  = gera_label("end_if");
                                        end_else = gera_label("end_else");
                                        $$.v = $2.v + begin_if + '?' + end_if + '#' + (':' + begin_if) + $3.v + (':' + end_if) + $4.v; }
       | IF COND CMD ';' P          {
                                        begin_if = gera_label("begin_if");
                                        end_if  = gera_label("end_if");
                                        end_else = gera_label("end_else");
                                        $$.v = $2.v + begin_if + '?' + end_if + '#' + (':' + begin_if) + $3.v + (':' + end_if) + $5.v; }
       | IF COND CMD ';'            {
                                        begin_if = gera_label("begin_if");
                                        end_if  = gera_label("end_if");
                                        end_else = gera_label("end_else");
                                        $$.v = $2.v + begin_if + '?' + end_if + '#' + (':' + begin_if) + $3.v + (':' + end_if); }
       ;

BLOCO_IF : '{' P '}' { $$.v = $2.v + end_else + '#'; }
         | CMD ';'   { $$.v = $1.v + end_else + '#'; }
         ;

CMD_ELSE : ELSE BLOCO       { $$.v = $2.v + (':' + end_else); }
         | ELSE CMD ';'     { $$.v = $2.v + (':' + end_else); }
         | ELSE CMD ';' P   { $$.v = $2.v + (':' + end_else) + $4.v; }
         | ELSE CMD_IF      { $$.v = $2.v + (':' + end_else);}
         ;

COND : '(' BOOL ')' { $$.v = $2.v; }
     ;

BOOL : E '<' E      { $$.v = $1.v + $3.v + '<';}
     | E '>' E      { $$.v = $1.v + $3.v + '>';}
     | E '=' '=' E      { $$.v = $1.v + $4.v + "==";}
     ;

BLOCO : '{' P '}'    { $$.v = $2.v;}

CMD : CMD_LET       { $$.v = $1.v;}
    | ATRIBUI       { $$.v = $1.v + '^';}
    ;

CMD_LET : LET IDS   { $$.v = $2.v;}
        ;

IDS : V ',' IDS     { $$.v = $1.v + $3.v;}
    | V             { $$.v = $1.v;}
    ;

V : ID                 { chk_duplicate_declaration($1.v[0]); $$.v = $1.v + '&'; }
  | ID '=' E           { chk_duplicate_declaration($1.v[0]); $$.v = $1.v + '&' + $1.v + $3.v + '=' + '^'; }
  ;

ATRIBUI : ID '=' ATRIBUI  { chk_atribuition_to_var($1.v[0]); $$.v = $1.v + $3.v + '=';}
        | ID '=' E        { chk_atribuition_to_var($1.v[0]); $$.v = $1.v + $3.v + '=';}
        | OBJETO '=' E       { $$.v = $1.v + $3.v + "[=]"; }
        | OBJETO '=' ATRIBUI { $$.v = $1.v + $3.v + "[=]"; }
        ;

OBJETO : ID '.' ID              { $$.v = $1.v + '@' + $3.v; }
       | ID '.' ID '[' E ']'    { $$.v = $1.v + '@' + $3.v + "[@]" + $5.v; }
       | ID '[' E ']'           { $$.v = $1.v + '@' + $3.v; }
       | ID '[' ATRIBUI ']'     { $$.v = $1.v + '@' + $3.v; }
       | ID '[' E ']' '[' E ']' { $$.v = $1.v + '@' + $3.v + "[@]" + $6.v; }
       ;

E : E '+' E { $$.v = $1.v + $3.v + '+'; }
  | E '-' E { $$.v = $1.v + $3.v + '-'; }
  | E '*' E { $$.v = $1.v + $3.v + '*'; }
  | E '/' E { $$.v = $1.v + $3.v + '/'; }
  | F
  ;
  
F : ID  { $$.v = $1.v + '@';}
  | '-' NUM { $$.v = '0' + $2.v + '-'; }
  | NUM { $$.v = $1.v;}
  | STR { $$.v = $1.v;}
  | ID '.' ID { $$.v = $1.v + '@' + $3.v + "[@]"; }
  | ID '[' E ']' '[' E ']' { $$.v = $1.v + '@' + $3.v + "[@]" + $6.v + "[@]"; }
  | '(' E ')'   { $$.v = $2.v; }
  | '{' '}'     { $$.v = vector<string>{"{}"}; }
  | '[' ']'     { $$.v = vector<string>{"[]"}; }
  | FUNC '(' PARAMS ')' { Print( $1.v + '#' ); }
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
    { NUM, "número" },
};

void chk_atribuition_to_var(string var) {
    if (variables_declaraction_line.count(var) < 1) {
        cerr << "Erro: a variável '" << var << "' não foi declarada." << endl;
        exit(1);
    }
}

void chk_duplicate_declaration(string var) {
    int quantity = variables_declaraction_line.count(var);
    if (quantity) {
        cerr << "Erro: a variável '" << var << "' já foi declarada na linha " << variables_declaraction_line[var] << "." << endl;
        exit(1);
    } else {
        variables_declaraction_line[var] = linha;
    }
}

string gera_label( string prefixo ) {
  static int n = 0;

  return prefixo + "_" + to_string( ++n ) + ":";
}

vector<string> resolve_enderecos( vector<string> entrada ) {
  map<string,int> label;
  vector<string> saida;

  for( int i = 0; i < entrada.size(); i++ ) 
    if( entrada[i][0] == ':' ) 
        label[entrada[i].substr(1)] = saida.size();
    else
      saida.push_back( entrada[i] );
  
  for( int i = 0; i < saida.size(); i++ ) 
    if( label.count( saida[i] ) > 0 )
        saida[i] = to_string(label[saida[i]]);
    
  return saida;
}

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
        << "Perto de : '" << yylval.v.back() << "'" <<endl;
    exit( 0 );
}

void Print( string st ) {
    cout << st << " ";
}

void Print( vector<string> st ) {
    for (string s : st )
        cout << s << " ";
}

int main() {
    yyparse();

    cout << endl;

    return 0;
}
