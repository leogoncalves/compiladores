let str = "hello";
function valor() { return str + ", world"; }
let a = valor();

=== Console ===
=== Vars ===
|{ a: hello, world; str: hello; undefined: undefined; valor: { &funcao: ##; }; }|
=== Pilha ===

function sqr(x) { return x\*x; }
let a = sqr( 5.2 );

=== Console ===
=== Vars ===
|{ a: 27.04; sqr: { &funcao: ##; }; undefined: undefined; }|
=== Pilha ===

function mdc( a, b ) {
if( b == 0 )
return a;
else
return mdc( b, a % b );
}

let a = mdc( 24, 33 );

=== Console ===
=== Vars ===
|{ a: 3; mdc: { &funcao: ##; }; undefined: undefined; }|
=== Pilha ===

function teste( a, b ) {
if( a > b )
return a;
}

let um = teste( 3, 4 ),
dois = teste( 4, 3 );

=== Console ===
=== Vars ===
|{ dois: 4; teste: { &funcao: ##; }; um: undefined; undefined: undefined; }|
=== Pilha ===

function log( msg ) {
msg asm{println # undefined};
}

let r = log( 'Hello, world!' );

=== Console ===
Hello, world!
=== Vars ===
|{ log: { &funcao: ##; }; r: undefined; undefined: undefined; }|
=== Pilha ===

let console = {};
let Number = {};

function log( msg ) {
msg asm{println # undefined};
}

function number_to_string( msg ) {
msg asm{to_string # '&retorno' @ ~};
}

console.log = log;
Number.toString = number_to_string;

let a = "Saida: ";
let b = 3.14;

console.log( a + Number.toString( b ) );

=== Console ===
Saida: 3.14
=== Vars ===
|{ Number: { toString: { &funcao: ##; }; }; a: Saida: ; b: 3.14; console: { log: { &funcao: ##; }; }; log: { &funcao: ##; }; number_to_string: { &funcao: ##; }; undefined: undefined; }|
=== Pilha ===
"

let console = {};

function exit( n ) {
'Codigo de erro: ' asm{print # undefined};
n asm{println # undefined};
0 asm{.};
}

function teste( a, b, c ) {
exit( b );
}

let a = "Saida: ";
let b = 3.14;

console.teste = {};
console.teste.log = [];
console.teste.log[1] = teste;

console.teste.log[1]( a, b, "5" );

=== Console ===
Codigo de erro: 3.14
=== Vars ===
|{ a: Saida: ; b: 3.14; console: { teste: { log: [ 0: undefined; 1: { &funcao: ##; }; ]; }; }; exit: { &funcao: ##; }; teste: { &funcao: ##; }; undefined: undefined; }|
|{ &retorno: ##; a: Saida: ; arguments: [ 0: Saida: ; 1: 3.14; 2: 5; ]; b: 3.14; c: 5; }|
|{ &retorno: ##; arguments: [ 0: 3.14; ]; n: 3.14; }|
=== Pilha ===
|0|

function f( x ) {
let b = 5 \* x;
let c = {};

c.num = b;
c.arr = [];
c.arr[1] = 0;
return c ;
}

let res = f( 11 );

=== Console ===
=== Vars ===
|{ f: { &funcao: ##; }; res: { arr: [ 0: undefined; 1: 0; ]; num: 55; }; undefined: undefined; }|
=== Pilha ===

function f( x ) {
let b = f;
f = x;
return b;
}

let a;
let g = f( a = [], {} );

=== Console ===
=== Vars ===
|{ a: [ ]; f: [ ]; g: { &funcao: ##; }; undefined: undefined; }|
=== Pilha ===

function getNome( obj ) { return obj.nome; }

function getClass( obj ) { return obj.class; }

function criaAluno( nome, celular, email ) {
let aluno = {};

aluno.nome = nome;
aluno.celular = celular;
aluno.email = email;
aluno.super = prototipoAluno;
aluno.getNome = getNome;

return aluno;
}

function log( msg ) {
msg asm{println # undefined};
}

function invoke( obj, metodo ) {
if( toString( obj[metodo] ) == 'undefined' )
return obj.super[metodo](obj.super);
else
return obj[metodo](obj);
}

function toString( msg ) {
msg asm{to_string # '&retorno' @ ~};
}

let prototipoAluno = {};

prototipoAluno.class = 'Classe Aluno';
prototipoAluno.getClass = getClass;

let joao = criaAluno( 'Joao', '123456', 'eu@aqui.com' );
let maria = criaAluno( 'Maria', '123457', 'voce@la.com' );

log( invoke( joao, 'getNome' ) );
log( invoke( joao, 'getClass' ) );
log( invoke( maria, 'getNome' ) );
log( invoke( maria, 'getClass' ) );

=== Console ===
Joao
Classe Aluno
Maria
Classe Aluno
=== Vars ===
|{ criaAluno: { &funcao: ##; }; getClass: { &funcao: ##; }; getNome: { &funcao: ##; }; invoke: { &funcao: ##; }; joao: { celular: 123456; email: eu@aqui.com; getClass: undefined; getNome: { &funcao: ##; }; nome: Joao; super: { class: Classe Aluno; getClass: { &funcao: ##; }; }; }; log: { &funcao: ##; }; maria: { celular: 123457; email: voce@la.com; getClass: undefined; getNome: { &funcao: ##; }; nome: Maria; super: { class: Classe Aluno; getClass: { &funcao: ##; }; }; }; prototipoAluno: { class: Classe Aluno; getClass: { &funcao: ##; }; }; toString: { &funcao: ##; }; undefined: undefined; }|
=== Pilha ===
