%{
#include <stdio.h>

void yyerror(char *s);
int yylex (void);

%}

%token TOKEN_LEFT_PAREN TOKEN_RIGHT_PAREN TOKEN_LEFT_BRACE TOKEN_RIGHT_BRACE
%token TOKEN_COMMA TOKEN_DOT TOKEN_MINUS TOKEN_PLUS TOKEN_SEMICOLON TOKEN_SLASH TOKEN_STAR
%token TOKEN_BANG TOKEN_BANG_EQUAL TOKEN_EQUAL TOKEN_EQUAL_EQUAL TOKEN_GREATER TOKEN_GREATER_EQUAL
%token TOKEN_LESS TOKEN_LESS_EQUAL TOKEN_IDENTIFIER TOKEN_STRING TOKEN_NUMBER
%token TOKEN_AND TOKEN_CLASS TOKEN_ELSE TOKEN_FALSE TOKEN_FOR TOKEN_FUN TOKEN_IF TOKEN_NIL TOKEN_OR
%token TOKEN_PRINT TOKEN_RETURN TOKEN_SUPER TOKEN_THIS TOKEN_TRUE TOKEN_VAR TOKEN_WHILE
%token TOKEN_ERROR TOKEN_EOF

%%

program: eval
;

eval: term
;

term: TOKEN_NUMBER
;

%%

void main(int argc, char *argv[]) {
	yyparse();
}

void yyerror(char *s) {
	fprintf(stderr, "error: %s\n", s);
}