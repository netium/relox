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

program: declaration* TOKEN_EOF;

declaration: classDecl
| funDecl
| varDecl
| statement
;

classDecl: "class" ( "<" TOKEN_IDENTIFIER)? "{" function* "}";

funDecl: "func" function;

varDecl: "var" TOKEN_IDENTIFIER ( "=" expression)? ";";

statement: exprStmt
| forStmt
| ifStmt
| printStmt
| returnStmt
| whileStmt
| block
;

exprStmt: expression ";";

forStmt: "for" "(" ( varDecl | exprStmt | ";") expression? ";" expression? ")" statement;

ifStmt: "if" "(" expression ")" statement ( "else" statement )? ;

printStmt: "print" expression ";" ;

returnStmt: "return" expression? ";" ;

whileStmt: "while" "(" expression ")" statement ;

block: "{" declaration* "}";

expression: assignment;

assignment: ( call ".")? TOKEN_IDENTIFER "=" assignment 
| logic_or
;

logic_or: logic_and ( "or" logic_and )* ;

logic_and: equality ( "and" equality )* ;

equality: comparison ( ( "!=" | "==") comparison )* ;

comparison: term (( ">" | ">=" | "<" | "<=") term)* ;

term: factor ( ( "-" | "+") factor)* ;

factor: unary ( ( "/" | "*" ) unary )* ;

unary: ("!" | "-" ) unary | call;

call: primary ( "(" arguments ? ")" | "." TOKEN_IDENTIFIER )*;

primary: TOKEN_TRUE 
| TOKEN_FALSE 
| TOKEN_NIL 
| TOKEN_THIS 
| TOKEN_NUMBER 
| TOKEN_STRING 
| TOKEN_IDENTIFIER 
| "(" expression ")" 
| TOKEN_SUPER "." TOKEN_IDENTIFIER
;

function: TOKEN_IDENTIFIER "(" parameters? ")" block;

parameters: TOKEN_IDENTIFIER ( "," TOKEN_IDENTIFIER )* ;

arguments: expression ( "," expression )* ;


%%

void main(int argc, char *argv[]) {
	yyparse();
}

void yyerror(char *s) {
	fprintf(stderr, "error: %s\n", s);
}