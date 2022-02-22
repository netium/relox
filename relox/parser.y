
%code {
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "memory.h"

#ifdef DEBUG_PRINT_CODE
#include "debug.h"
#endif

#include "parser_helper.h"
}

%union {
	int code_offset; 
	double number;
	char literal[256];
}

%define api.token.prefix {TOKEN_}

%token BANG_EQUAL "!=" 
%token EQUAL_EQUAL "=="
%token GREATER_EQUAL ">="
%token LESS_EQUAL "<="
%token AND "&&"
%token CLASS "class"
%token ELSE "else" 
%token FALSE "false"
%token FOR "for"
%token FUN "func"
%token IF "if"
%token NIL "nil"
%token OR "||"
%token PRINT "print"
%token RETURN "return"
%token SUPER "super" 
%token THIS "this"
%token TRUE 235 "true"
%token VAR "var"
%token WHILE "while"
%token UMINUS
%token <literal> IDENTIFIER
%token <literal> STRING
%token <number> NUMBER

%nterm program

%right '='
%nonassoc '>' '<' "==" "!=" ">=" "<="
%left "||"
%left "&&"
%left '+' '-'
%left '*' '/'
%left UMINUS '!'

%start program

%%

program: declarations 
;

declaration: classDecl
| funDecl
| varDecl
| statement
;

classDecl: "class" IDENTIFIER '{' functions '}'	
| "class" IDENTIFIER ':' IDENTIFIER '{' functions '}'
;

functions: 
%empty
| funDecl functions
;

funDecl: "func" function;

varDecl: "var" IDENTIFIER ';'
| "var" IDENTIFIER '=' expression ';'
;

statement: exprStmt
| forStmt
| ifStmt
| printStmt
| returnStmt
| whileStmt
| block
;

exprStmt: expression ';' { emitByte(OP_POP); }
;

forStmt: "for" '(' forInit forCondExpr ';' forIterExpr ')' statement;

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
"if" '(' expression ')' statement
|"if" '(' expression ')' statement "else" statement 
;

printStmt: "print" expression ';' { emitByte(OP_PRINT); }
;

returnStmt: returnContextCheck "return" ';'	{ emitReturn(); }
| returnContextCheck "return" {
	if (current->type == TYPE_INITIALIZER) {
		fprintf(yyo, "%s", "Cannot return a value from an initializer.");
		YYABORT;
	}
} expression ';'	{ emitByte(OP_RETURN); }
;

returnContextCheck: %empty {
	if (current->type == TYPE_SCRIPT) {
		fprintf(yyo, "%s", "CAnnot return from top-level code.");
		YYABORT;
	}
}

whileStmt: "while" <code_offset>{
	$loopStart = currentChunk()->count;
}[loopStart] '(' expression ')' <code_offset>{
	$exitJump = emitJump(OP_JUMP_IF_FALSE);
}[exitJump] statement  {
	emitLoop($loopStart);
	patchJump($exitJump);
	emitByte(OP_POP);
}
;

block: '{' declarations '}'
| error '}' { yyerrok; } ;

declarations:
%empty
| declarations declaration 
;

expression: assignment;

assignment:
call '.' IDENTIFIER '=' assignment
| IDENTIFIER '=' assignment 
| expr 
;

expr: 
expr "||" expr		{}
| expr "&&" expr	{}
| expr "!=" expr	{ emitBytes(OP_EQUAL, OP_NOT); }
| expr "==" expr	{ emitByte(OP_EQUAL); }
| expr '>' expr			{ emitByte(OP_GREATER); }
| expr ">=" expr	{ emitBytes(OP_LESS, OP_NOT); } 
| expr '<' expr			{ emitByte(OP_LESS); } 
| expr "<=" expr	{ emitBytes(OP_GREATER, OP_NOT); } 
| expr '+' expr			{ emitByte(OP_ADD); } 
| expr '-' expr			{ emitByte(OP_SUBTRACT); } 
| expr '*' expr			{ emitByte(OP_MULTIPLY); } 
| expr '/' expr			{ emitByte(OP_DIVIDE); } 
| '!' expr			{ emitByte(OP_NOT); } 
| '-' expr %prec UMINUS		{ emitByte(OP_NEGATE); } 
| '(' expr ')'			/* Do nothing */
| call
; 

call: primary
| call '(' arguments ')' 
| call '.' IDENTIFIER
;

primary: "true" { emitByte(OP_TRUE); } 
| "false" { emitByte(OP_FALSE); }
| "nil" { emitByte(OP_NIL); } 
| "this"
| NUMBER[number]			{ emitConstant(NUMBER_VAL($number)); } 
| STRING[string]			{ emitConstant(OBJ_VAL(copyString($string, strlen($string)))); }	
| IDENTIFIER[id]
| "super" '.' IDENTIFIER[id]
;

function: IDENTIFIER '(' parameters ')' block
| IDENTIFIER
;

parameters: 
%empty
| IDENTIFIER
| parameters ',' IDENTIFIER
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