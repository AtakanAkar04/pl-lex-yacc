parser: lex.yy.c y.tab.c 
	gcc -o parser y.tab.c
y.tab.c: CS315_S25_Team2.yacc lex.yy.c
	yacc CS315_S25_Team2.yacc
lex.yy.c: CS315_S25_Team2.lex
	lex CS315_S25_Team2.lex
clean:
	rm -f lex.yy.c y.tab.c parser
