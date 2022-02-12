
%{
#include <stdio.h>
#include <string.h>
#include "parser_helper.h"

int yylex (void);

%}

%union {
	double value;
	char id[256];
}

%token TOKEN_LEFT_PAREN TOKEN_RIGHT_PAREN TOKEN_LEFT_BRACE TOKEN_RIGHT_BRACE
%token TOKEN_COMMA TOKEN_DOT TOKEN_MINUS TOKEN_PLUS TOKEN_SEMICOLON TOKEN_SLASH TOKEN_STAR
%token TOKEN_BANG TOKEN_BANG_EQUAL TOKEN_EQUAL TOKEN_EQUAL_EQUAL TOKEN_GREATER TOKEN_GREATER_EQUAL
%token TOKEN_LESS TOKEN_LESS_EQUAL TOKEN_STRING TOKEN_NUMBER
%token TOKEN_AND TOKEN_CLASS TOKEN_ELSE TOKEN_FALSE TOKEN_FOR TOKEN_FUN TOKEN_IF TOKEN_NIL TOKEN_OR
%token TOKEN_PRINT TOKEN_RETURN TOKEN_SUPER TOKEN_THIS TOKEN_TRUE TOKEN_VAR TOKEN_WHILE
%token TOKEN_ERROR TOKEN_EOF
%token <id> TOKEN_IDENTIFIER

%start program

%%

program: declarations;

statements: 
| statement statements;

declaration: classDecl
| funDecl
| varDecl
| statement
;

classDecl: TOKEN_CLASS TOKEN_IDENTIFIER '{' functions '}'	
| TOKEN_CLASS ':' TOKEN_IDENTIFIER '{' functions '}'
;

functions: 
| function functions
;

funDecl: TOKEN_FUN function;

varDecl: TOKEN_VAR TOKEN_IDENTIFIER ';'
| TOKEN_VAR TOKEN_IDENTIFIER '=' expression ';'
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

forStmt: TOKEN_FOR '(' forInit forCondExpr ';' forIterExpr ')' statement;

forInit: varDecl
| exprStmt
| ';'
;

forCondExpr: 
| expression
;

forIterExpr:
| expression
;

ifStmt: 
TOKEN_IF '(' expression ')' statement
| TOKEN_IF'(' expression ')' statement TOKEN_ELSE statement 
;

printStmt: TOKEN_PRINT expression ';' ;

returnStmt: TOKEN_RETURN ';'
| TOKEN_RETURN expression ';' 
;

whileStmt: TOKEN_WHILE '(' expression ')' statement ;

block: '{' declarations '}' ;

declarations:
| declaration declarations
;

expression: assignment;

assignment:
call '.' TOKEN_IDENTIFIER '=' assignment
| TOKEN_IDENTIFIER '=' assignment 
| logic_or
;

logic_or: logic_and
| logic_or TOKEN_OR logic_and
;

logic_and: equality
| logic_and TOKEN_AND equality
;

equality: comparison
| equality TOKEN_BANG_EQUAL comparison
| equality TOKEN_EQUAL_EQUAL comparison
;

comparison: term 
| term '>' term
| term TOKEN_GREATER_EQUAL term
| term '<' term
| term TOKEN_LESS_EQUAL term
;

term: factor 
| term '+' factor
| term '-' factor
;

factor: unary
| factor '/' unary
| factor '*' unary
;

unary: '!' unary
| '-' unary
| call
;

call: primary
| functionCall
| referenceCall
;

functionCall: call '(' arguments ')';

referenceCall: call '.' TOKEN_IDENTIFIER;


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
| TOKEN_IDENTIFIER
;

parameters: 
| TOKEN_IDENTIFIER
| parameters ',' TOKEN_IDENTIFIER
;

arguments:
| expression
| arguments ',' expression
;


%%

void main(int argc, char *argv[]) {
	yyparse();
}