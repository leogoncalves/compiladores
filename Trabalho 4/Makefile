all: gerador_fi entrada.txt
	./gerador_fi < entrada.txt

gerador_fi: lex.yy.c y.tab.c 
	g++ y.tab.c -o gerador_fi -lfl 
	
lex.yy.c: gerador_fi.l
	lex gerador_fi.l
	
y.tab.c: gerador_fi.y
	yacc gerador_fi.y
	
clean: 
	rm -f lex.yy.c y.tab.c gerador_fi