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

statements: statements statement TOKEN_EOF;

declaration: classDecl
| funDecl
| varDecl
| statement
;

classDecl: 'class' ( TOKEN_LESS TOKEN_IDENTIFIER)? '{' function* '}';

funDecl: TOKEN_FUN function;

varDecl: 'var' TOKEN_IDENTIFIER ';'
| 'var' TOKEN_IDENTIFIER '=' expression ';'
;

statement: exprStmt
| forStmt
| ifStmt
| printStmt
| returnStmt
| whileStmt
| block
;

exprStmt: expression ';';

forStmt: 'for' '(' ( varDecl | exprStmt | ';') expression? ";" expression? ')' statement;

ifStmt: 
'if' '(' expression ')' statement
|'if' '(' expression ')' statement 'else' statement 
;

printStmt: 'print' expression ';' ;

returnStmt: 'return' ';'
| 'return' expression ';' 
;

whileStmt: TOKEN_WHILE TOKEN_LEFT_PAREN expression TOKEN_RIGHT_PAREN statement ;

block: TOKEN_LEFT_BRACE declaration* TOKEN_RIGHT_BRACE;

expression: assignment;

assignment:
call '.' TOKEN_IDENTIFIER '=' assignment
 TOKEN_IDENTIFIER '=' assignment 
| logic_or
;

logic_or: logic_and
| logic_or '||' logic_and
;

logic_and: equality
| logic_and '&&' equality
;

equality: comparison
| equality '!=' comparison
| equality '==' comparison
;

comparison: term 
| term '>' term
| term '>=' term
| term '<' term
| term '<=' term
;

term: factor 
| term '+' factor
| term '-' factor
;

factor: unary
| factor TOKEN_SLASH unary
| factor TOKEN_STAR unary
;

unary: TOKEN_BANG unary
| TOKEN_MINUS unary
| call
;

call: primary ( '(' arguments ? ')' | '.' TOKEN_IDENTIFIER )*;

primary: TOKEN_TRUE 
| TOKEN_FALSE 
| TOKEN_NIL 
| TOKEN_THIS 
| TOKEN_NUMBER 
| TOKEN_STRING 
| TOKEN_IDENTIFIER 
| TOKEN_LEFT_PAREN expression TOKEN_RIGHT_PAREN
| TOKEN_SUPER TOKEN_DOT TOKEN_IDENTIFIER
;

function: TOKEN_IDENTIFIER '(' parameters ')' block
TOKEN_IDENTIFIER;

parameters: 
| TOKEN_IDENTIFIER
| parameters ',' TOKEN_IDENTIFIER
;

arguments: expression
| arguments ',' expression
;


%%

void main(int argc, char *argv[]) {
	yyparse();
}

void yyerror(char *s) {
	fprintf(stderr, "error: %s\n", s);
}