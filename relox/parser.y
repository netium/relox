
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "memory.h"

#ifdef DEBUG_PRINT_CODE
#include "debug.h"
#endif

#include "parser_helper.h"

void emitByte(uint8_t byte);
void emitBytes(uint8_t byte1, uint8_t byte2);
void emitConstant(Value value);
uint8_t makeConstant(Value value);
void emitReturn();
int emitJump(uint8_t instruction);

int yylex (void);

%}

%union {
	double value;
	char literal[256];
}

%token TOKEN_BANG_EQUAL TOKEN_EQUAL_EQUAL TOKEN_GREATER_EQUAL
%token TOKEN_LESS_EQUAL
%token TOKEN_AND TOKEN_CLASS TOKEN_ELSE TOKEN_FALSE TOKEN_FOR TOKEN_FUN TOKEN_IF TOKEN_NIL TOKEN_OR
%token TOKEN_PRINT TOKEN_RETURN TOKEN_SUPER TOKEN_THIS TOKEN_TRUE TOKEN_VAR TOKEN_WHILE
%token TOKEN_ERROR TOKEN_EOF
%token TOKEN_UMINUS
%token <literal> TOKEN_IDENTIFIER
%token <literal> TOKEN_STRING
%token <literal> TOKEN_NUMBER

%nterm program

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

declaration: classDecl
| funDecl
| varDecl
| statement
;

classDecl: TOKEN_CLASS TOKEN_IDENTIFIER '{' functions '}'	
| TOKEN_CLASS TOKEN_IDENTIFIER ':' TOKEN_IDENTIFIER '{' functions '}'
;

functions: 
%empty
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
%empty
| expression
;

forIterExpr:
%empty
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
%empty
| declarations declaration 
;

expression: assignment;

assignment:
call '.' TOKEN_IDENTIFIER '=' assignment
| TOKEN_IDENTIFIER '=' assignment 
| expr 
;

expr: expr TOKEN_OR expr	
| expr TOKEN_AND expr
| expr TOKEN_BANG_EQUAL expr	{ emitBytes(OP_EQUAL, OP_NOT); }
| expr TOKEN_EQUAL_EQUAL expr	{ emitByte(OP_EQUAL); }
| expr '>' expr			{ emitByte(OP_GREATER); }
| expr TOKEN_GREATER_EQUAL expr	{ emitBytes(OP_LESS, OP_NOT); } 
| expr '<' expr			{ emitByte(OP_LESS); } 
| expr TOKEN_LESS_EQUAL expr	{ emitBytes(OP_GREATER, OP_NOT); } 
| expr '+' expr			{ emitByte(OP_ADD); } 
| expr '-' expr			{ emitByte(OP_SUBTRACT); } 
| expr '*' expr			{ emitByte(OP_MULTIPLY); } 
| expr '/' expr			{ emitByte(OP_DIVIDE); } 
| '!' expr			{ emitByte(OP_NOT); } 
| '-' expr %prec TOKEN_UMINUS	{ emitByte(OP_NEGATE); } 
| '(' expr ')'
| call
; 

call: primary
| call '(' arguments ')' 
| call '.' TOKEN_IDENTIFIER
;

primary: TOKEN_TRUE		{ emitByte(OP_TRUE); } 
| TOKEN_FALSE			{ emitByte(OP_FALSE); }
| TOKEN_NIL			{ emitByte(OP_NIL); } 
| TOKEN_THIS 
| TOKEN_NUMBER			{ double value = strtod($1, NULL); emitConstant(NUMBER_VAL(value)); } 
| TOKEN_STRING			{ emitConstant(OBJ_VAL(copyString($1, strlen($1)))); }	
| TOKEN_IDENTIFIER 
| TOKEN_SUPER '.' TOKEN_IDENTIFIER
;

function: TOKEN_IDENTIFIER '(' parameters ')' block
| TOKEN_IDENTIFIER
;

parameters: 
%empty
| TOKEN_IDENTIFIER
| parameters ',' TOKEN_IDENTIFIER
;

arguments:
%empty
| expression
| arguments ',' expression
;


%%

/*
void main(int argc, char *argv[]) {
	yyparse();
}
*/