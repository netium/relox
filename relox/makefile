all: lex.yy.c parser.tab.c
	gcc parser.tab.c lex.yy.c -lfl

lex.yy.c: lexer.l 
	flex lexer.l

parser.tab.c: parser.y
	bison -d parser.y

