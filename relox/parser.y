
%code {
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "common.h"
#include "memory.h"

#ifdef DEBUG_PRINT_CODE
#include "debug.h"
#endif

#include "parser_helper.h"

}

%union {
	unsigned char var_index;
	int is_lval;
	int argc;
	int code_offset; 
	double number;
	char literal[256];
}

%define api.token.prefix {TOKEN_}

%nterm <argc> arguments
%nterm <argc> argument
%nterm <code_offset> forCondExpr
%nterm <is_lval> primary
%nterm <is_lval> call

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

classDecl: "class" IDENTIFIER[id]
{
	uint8_t nameConstant = identifierConstant(&parser.previous);
	declareVariable($id);

	emitBytes(OP_CLASS, nameConstant);
	defineVariable(nameConstant);

	ClassCompiler classCompiler;
	classCompiler.hasSuperclass = false;
	classCompiler.enclosing = currentClass;
	currentClass = &classCompiler;
} '{' 
{
	beginScope();
	addLocal(syntheticToken("super"));
	defineVariable(0);
	namedVariable($id, false);
} 
methods '}'
{
	emitByte(OP_POP);
	if (classCompiler.hasSuperclass) {
		endScope();
	}
	currentClass = currentClass->enclosing;
}
| "class" IDENTIFIER[classId] {
	uint8_t nameConstant = identifierConstant(&parser.previous);
	declareVariable($classId);

	emitBytes(OP_CLASS, nameConstant);
	defineVariable(nameConstant);

	ClassCompiler classCompiler;
	classCompiler.hasSuperclass = false;
	classCompiler.enclosing = currentClass;
	currentClass = &classCompiler;
} 
':' IDENTIFIER[id] {
	variable(false);
	if (identifierEqual($classId, $id)) {
		error("A class cannot inherit from itself.");
	}

	namedVariable($classId, false);
	emitByte(OP_INHERIT);
	classCompiler.hasSuperclass = true;
} '{'
{	
	beginScope();
	addLocal(syntheticToken("super"));
	defineVariable(0);
	namedVariable(className, false);
} 
methods '}'
{
	emitByte(OP_POP);
	if (classCompiler.hasSuperclass) {
		endScope();
	}
	currentClass = currentClass->enclosing;
}
;

methods: methodDecl
| methods methodDecl
;

methodDecl: IDENTIFIER[id] <var_index> {
	$constant = identifierConstant($id);
	FunctionType type = strcmp($id, "init")? TYPE_INITIALIZER : TYPE_METHOD;
	Compiler compiler;
	initCompiler(&compiler, type);
	beginScope();

 }[constant] '(' parameters ')' {
	 if (current->function->arity > 255) {
		 errorAtCurrent("Cannot have more than 255 parameters.");
	 }
 } block {
	 ObjFunction * function = endCompiler();
	 emitBytes(OP_CLOSURE, makeConstant(OBJ_VAL(function)));
	 for (int i = 0; i < function->upvalueCount; i++) {
		 emitByte(compiler.upvalues[i].isLocal ? 1 : 0);
		 emitByte(compiler.upvalues[i].index);
	 }

	emitBytes(OP_METHOD, $constant);
 }
;

functions: 
%empty
| functions funDecl
;

funDecl: "func" function;

varDecl: "var" IDENTIFIER[id] <var_index> {
	$global = parseVariable($id);
}[global] varInit ';' {
	defineVariable($global);
}
;

varInit:
%empty { emitByte(OP_NIL); }
| expression
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

forStmt: "for" { beginScope(); } '(' forInit <code_offset>{
	$loopStart = currentChunk()->count;
}[loopStart]
forCondExpr[exitJump] ';' forIterExpr ')' statement {
	emitLoop($loopStart);

	if ($exitJump != -1) {
		patchJump($exitJump);
		emitByte(OP_POP);
	}

	endScope();
};

forInit: varDecl
| exprStmt
| ';'
;

forCondExpr[exitJump]: 
%empty { $exitJump = -1; }
| expression { $exitJump = emitJump(OP_JUMP_IF_FALSE); emitByte(OP_POP); }
;

forIterExpr:
%empty
| expression
;

ifStmt: 
"if" '(' expression ')' <code_offset>{
	int thenJump = emitJump(OP_JUMP_IF_FALSE);
	emitByte(OP_POP);
	$$ = thenJump;
}[thenJump] statement <code_offset> {
	int elseJump = emitJump(OP_JUMP);
	patchJump($thenJump);
	emitByte(OP_POP);
	$$ = elseJump;
}[elseJump] elseClause {
	patchJump($elseJump);
};

elseClause:
%empty
| "else" statement
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
call {
	if (!$call) error("Cannot assign");
} '=' assignment {

}
| expr 
;

expr: 
expr "||" <code_offset>{
	int elseJump = emitJump(OP_JUMP_IF_FALSE);
	int endJump = emitJump(OP_JUMP);
	patchJump(elseJump);
	emitByte(OP_POP);
	$endJump = endJump;
}[endJump] expr		{ patchJump($endJump); }
| expr "&&" <code_offset>{
	int endJump = emitJump(OP_JUMP_IF_FALSE);

	emitByte(OP_POP);

	$endJump = endJump;
}[endJump] expr	{ patchJump($endJump); }
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

call: primary { $$ = $primary; }
| call '(' arguments ')' { uint8_t argCount = $arguments; emitBytes(OP_INVOKE, name); emitByte(argCount); $$ = 0; } 
| call '.' IDENTIFIER { $$ = 1; }
;

primary: "true" { emitByte(OP_TRUE); $$ = 0; } 
| "false" { emitByte(OP_FALSE); $$ = 0; }
| "nil" { emitByte(OP_NIL); $$ = 0; } 
| "this" { $$ = 0; }
| NUMBER[number]			{ emitConstant(NUMBER_VAL($number)); $$ = 0; } 
| STRING[string]			{ emitConstant(OBJ_VAL(copyString($string, strlen($string)))); $$ = 0; }	
| IDENTIFIER[id]			{ $$ = 1; }
| "super" { $$ = 0; }
;

function: IDENTIFIER[id] <var_index> {
	$global = parseVariable($id);
	markInitialized();
	Compiler compiler;
	initCompiler(&compiler, TYPE_FUNCTION);
	beginScope();
 }[global] '(' parameters ')' {
	 if (current->function->arity > 255) {
		 errorAtCurrent("Cannot have more than 255 parameters.");
	 }
 } block {
	 ObjFunction* function = endCompiler();
	 emitBytes(OP_CLOSURE, makeConstant(OBJ_VAL(function)));
	 for (int i = 0; i < function->upvalueCount; i++) {
		 emitByte(compiler.upvalues[i].isLocal ? 1 : 0);
		 emitByte(compiler.upvalues[i].index);
	 }
	defineVariable($global);
 }
;

parameters: 
%empty
| IDENTIFIER[id] { uint8_t constant = parseVariable($id); defineVariable(constant); }
| parameters ',' IDENTIFIER[id] { uint8_t constant = parseVariable($id); defineVariable(constant); }
;

arguments:
%empty { $arguments = 0; }
| argument { $arguments = $argument; }
| arguments ',' argument { $$ = $1 + $argument; }
;


argument:
expression { $argument = 1; }
;

%%

/*
void main(int argc, char *argv[]) {
	yyparse();
}
*/