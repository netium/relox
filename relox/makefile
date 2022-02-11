all: lex.yy.c parser.tab.c parser_helper.c
	gcc parser.tab.c lex.yy.c parser_helper.c -lfl

lex.yy.c: lexer.l 
	flex lexer.l

parser.tab.c: parser.y
	bison -d parser.y

