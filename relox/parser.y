
%{
#include <stdio.h>
#include <string.h>
#include "parser_helper.h"

int yylex (void);

%}

%union {
	double value;
	char literal[256];
}

%token TOKEN_LEFT_PAREN TOKEN_RIGHT_PAREN TOKEN_LEFT_BRACE TOKEN_RIGHT_BRACE
%token TOKEN_COMMA TOKEN_DOT TOKEN_MINUS TOKEN_PLUS TOKEN_SEMICOLON TOKEN_SLASH TOKEN_STAR
%token TOKEN_BANG TOKEN_BANG_EQUAL TOKEN_EQUAL TOKEN_EQUAL_EQUAL TOKEN_GREATER TOKEN_GREATER_EQUAL
%token TOKEN_LESS TOKEN_LESS_EQUAL
%token TOKEN_AND TOKEN_CLASS TOKEN_ELSE TOKEN_FALSE TOKEN_FOR TOKEN_FUN TOKEN_IF TOKEN_NIL TOKEN_OR
%token TOKEN_PRINT TOKEN_RETURN TOKEN_SUPER TOKEN_THIS TOKEN_TRUE TOKEN_VAR TOKEN_WHILE
%token TOKEN_ERROR TOKEN_EOF
%token TOKEN_UMINUS
%token <literal> TOKEN_IDENTIFIER
%token <literal> TOKEN_STRING
%token <literal> TOKEN_NUMBER

%right '='
%nonassoc '>' '<' TOKEN_EQUAL_EQUAL TOKEN_BANG_EQUAL TOKEN_GREATER_EQUAL TOKEN_LESS_EQUAL
%left TOKEN_OR
%left TOKEN_AND
%left '+' '-'
%left '*' '/'
%left TOKEN_UMINUS '!'

%start program

%%

program: declarations ;

statements: 
| statement statements;

declaration: classDecl
| funDecl
| varDecl
| statement
;

classDecl: TOKEN_CLASS TOKEN_IDENTIFIER '{' functions '}'	
| TOKEN_CLASS TOKEN_IDENTIFIER ':' TOKEN_IDENTIFIER '{' functions '}'
;

functions: 
| funDecl functions
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
| expr 
;

expr: expr TOKEN_OR expr
| expr TOKEN_AND expr
| expr TOKEN_BANG_EQUAL expr 
| expr TOKEN_EQUAL_EQUAL expr 
| expr '>' expr 
| expr TOKEN_GREATER_EQUAL expr 
| expr '<' expr 
| expr TOKEN_LESS_EQUAL expr 
| expr '+' expr 
| expr '-' expr 
| expr '*' expr 
| expr '/' expr 
| '!' expr 
| '-' expr %prec TOKEN_UMINUS 
| '(' expr ')'
| call
; 

call: primary
| call '(' arguments ')' 
| call '.' TOKEN_IDENTIFIER
;

primary: TOKEN_TRUE 
| TOKEN_FALSE 
| TOKEN_NIL 
| TOKEN_THIS 
| TOKEN_NUMBER 
| TOKEN_STRING 	
| TOKEN_IDENTIFIER 
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

/*
void main(int argc, char *argv[]) {
	yyparse();
}
*/