all: saida teste0
	./saida < teste0

test: saida teste1 teste2 teste3 teste4 teste6 teste7 teste8 teste9 teste10
	./saida < teste1
	./saida < teste2
	./saida < teste3
	./saida < teste4
	./saida < teste5
	./saida < teste6
	./saida < teste7
	./saida < teste8
	./saida < teste9
	./saida < teste10

saida:  main.cc
	lex main.cc
	g++ lex.yy.c -o saida -lfl


clean: saida 
	rm saida lex.yy.c
	
