%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>
#include <map>

extern "C" int yylex();

using namespace std;

int token;
string lexema;

void A();
void E();
void E_LINHA();
void T();
void T_LINHA();
void F();
void G();
void H();
void casa(int);

enum { tk_int = 256, tk_cte_int, tk_double, tk_char, tk_id, tk_float, tk_string, tk_print, tk_fun };

map<int,string> nome_tokens = {
  { tk_int, "int" },
  { tk_char, "char"},
  { tk_double, "double" },
  { tk_id, "nome de identificador" },
  { tk_cte_int, "const int"},
  { tk_float, "floating point"},
  { tk_fun, "function"},
  { tk_string, "string" },
  { tk_print, "print"}
};



%}

WS          [ \n\t]
D      [0-9]
L       [A-Za-z_]

NUM         {D}+
ID          {L}({L}|{D})*
PRINT       [Pp][Rr][Ii][Nn][Tt]
FUN      {ID}"("
FLOAT       {D}+("."{D}+)?([Ee][+\-]?{D}+)?
STRING      (\"(\\.|[^"\\])*\")+

%%

{WS}	 { }    
{NUM}	 { lexema = yytext; return tk_cte_int; }
{STRING} { lexema = yytext; return tk_string; } 
{FLOAT}	 { lexema = yytext; return tk_float; }
{PRINT}  { lexema = yytext; return tk_print; }
{FUN}    { lexema = yytext; return tk_fun; }
"char"   { lexema = yytext; return tk_char;}
"int"    { lexema = yytext; return tk_int;}
"double" { lexema = yytext; return tk_double;}

{ID}	 { lexema = yytext; return tk_id; }

.        { return yytext[0]; }

%%

int next_token() {
  return yylex();
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

void P() {
    casa(tk_print);
    E();
    cout << "print #" << " ";
}

void A() {
    string lexema = yytext;
    casa(tk_id);
    cout << lexema << " ";
    casa('=');
    E();
    casa(';');
    cout << "=" << " ";
}

void E() {
    T();
    E_LINHA();
}

void E_LINHA() {
    switch(token){
        case '+' : 
            casa( '+' ); 
            T();
            cout << "+" << " ";
            E_LINHA();
            break;
        case '-' : 
            casa( '-' ); 
            T();
            cout << "-" << " ";
            E_LINHA();
            break;
    }
}

void T() {
    F();
    T_LINHA();
}

void T_LINHA() {
    switch(token){
        case '*': 
            casa( '*' );
            F(); 
            cout << "*" << " ";
            T_LINHA(); 
            break;
        case '/':
            casa( '/' );
            F();
            cout << "/" << " ";
            T_LINHA();
            break;
    }
}

void F(){
    switch (token){
        case tk_id:{
            string lexema = yytext;
            casa( tk_id );
            cout << lexema << " @" << " "; }
            break;
        case tk_cte_int:{
            string lexema = yytext;
            casa( tk_cte_int );
            cout << lexema << " "; }
            break;
        case tk_float:{
            string lexema = yytext;
            casa ( tk_float ); 
            cout << lexema << " "; }
            break;
        case '(':{ 
            casa( '(' ); 
            E();
            casa( ')' ); }
            break;
        case tk_string:{
            string lexema = yytext;
            casa ( tk_string ); 
            cout << lexema << " "; }
            break;
        case tk_fun:{
            string lexema = yytext;
            casa(tk_fun);
            cout << lexema << " ";
        }
            break;
        default:
            break;
    }    
}


void H() {
    switch(token) {
        case tk_id:
            G();
            break;
        case tk_print:
            P();
            break;
    }
}


void G() {
    A();
    H();
}


void casa(int esperado) {
    if(token == esperado){
        token = next_token();
    } else {
        cout << "Esperado '" << nome_token(esperado)
        << "', encontrado '" << nome_token(token) << "'"<< endl;
        exit(1);
    }
}


int main() {
    
    while((token = next_token())){
        H();
    }
    return 0;
}