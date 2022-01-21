%{
#include <stdio.h>
#include "parser.tab.h"
%}

%%

"var" 	{ return TOKEN_VAR; }
"class" { return TOKEN_CLASS; }
"func"	{ return TOKEN_FUN; }
"return" { return TOKEN_RETURN; }
"nil"	{ printf("NIL\n"); return TOKEN_NIL; }
"true" 	{ printf("TRUE\n"); return TOKEN_TRUE; }
"false" { printf("FALSE\n"); return TOKEN_FALSE; }
"if"	{ printf("IF\n");  return TOKEN_IF; }
"else"	{ printf("ELSE\n"); return TOKEN_ELSE;}
"while"	{ printf("WHILE\n"); return TOKEN_WHILE; }
"for"	{ printf("FOR\n"); return TOKEN_FOR; }
"print" { printf("PRINT\n"); return TOKEN_PRINT; }
"this"	{ printf("THIS\n"); return TOKEN_THIS; }
"super" { printf("SUPER\n"); return TOKEN_SUPER; }
"&&"	{ printf("AND_AND\n"); return TOKEN_AND; }
"||"	{ printf("ABS_ABS\n"); return TOKEN_OR; }
"/"	{ printf("SLASH\n"); return TOKEN_SLASH; }
"*"	{ printf("STAR\n"); return TOKEN_STAR; }
"{"	{ printf("LBRACE\n"); return TOKEN_LEFT_BRACE; }
"}"	{ printf("RBRACE\n");	return TOKEN_RIGHT_BRACE; }
"("	{ printf("LPAREN\n"); return TOKEN_LEFT_PAREN; }
")"	{ printf("RPAREN\n"); return TOKEN_RIGHT_PAREN; }
"=="	{ printf("EQUAL_EQUAL\n"); return TOKEN_EQUAL_EQUAL; }
"="	{ printf("EQUAL\n"); return TOKEN_EQUAL; }
"!="	{ printf("BAND_EQUAL\n"); return TOKEN_BANG; }
">="	{ printf("GREATER_EQUAL\n"); return TOKEN_GREATER_EQUAL; }
">"	{ printf("GREATER\n"); return TOKEN_GREATER; }
"<="	{ printf("LESS_EQUAL\n"); return TOKEN_LESS_EQUAL; }
"<"	{ printf("LESS\n"); return TOKEN_LESS; }
"."	{ printf("DOT\n"); return TOKEN_DOT; }
";"	{ printf("SEMICOLON\n"); return TOKEN_SEMICOLON; }
","	{ printf("COMMA\n"); return TOKEN_COMMA; }
[a-zA-Z_][a-zA-Z0-9_]*	{ printf("IDENTIFIER %s\n", yytext); return TOKEN_IDENTIFIER; }
[0-9]+(\.[0-9]+)?	{ printf("NUMBER %s\n", yytext); return TOKEN_NUMBER; }
"+"	{ printf("PLUS\n"); return TOKEN_PLUS; }
"-"	{ printf("MINUS\n"); return TOKEN_MINUS; }
\/\/[^\n]*\n	{ printf("COMMENT %s", yytext); }
\"([^"]|(\\\.))*\"	{ printf("STRING %s", yytext); }
[ \t\r]	{}
.	{ printf("ERROR %s \n", yytext); }

%%

