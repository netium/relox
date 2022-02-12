%option noyywrap nodefault yylineno

%{
#include <stdio.h>
#include "parser.tab.h"
%}

%%
"var" 	{ printf("VAR\n"); return TOKEN_VAR; }
"class" { printf("CLASS\n"); return TOKEN_CLASS; }
"func"	{ printf("FUNC\n"); return TOKEN_FUN; }
"return" { printf("RETURN\n"); return TOKEN_RETURN; }
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
"/"	{ printf("/\n"); return yytext[0]; }
"*"	{ printf("*\n"); return yytext[0]; }
"{"	{ printf("{\n"); return yytext[0]; }
"}"	{ printf("}\n");	return yytext[0]; }
"("	{ printf("(\n"); return yytext[0]; }
")"	{ printf(")\n"); return yytext[0]; }
"=="	{ printf("EQUAL_EQUAL\n"); return TOKEN_EQUAL_EQUAL; }
"="	{ printf("EQUAL\n"); return yytext[0]; }
"!="	{ printf("BAND_EQUAL\n"); return TOKEN_BANG; }
">="	{ printf("GREATER_EQUAL\n"); return TOKEN_GREATER_EQUAL; }
">"	{ printf("GREATER\n"); return yytext[0]; }
"<="	{ printf("LESS_EQUAL\n"); return TOKEN_LESS_EQUAL; }
"<"	{ printf("LESS\n"); return yytext[0]; }
"."	{ printf("DOT\n"); return yytext[0]; }
";"	{ printf("SEMICOLON\n"); return yytext[0]; }
":" { printf("COLON\n"); return yytext[0]; }
","	{ printf("COMMA\n"); return yytext[0]; }
[a-zA-Z_][a-zA-Z0-9_]*	{ printf("IDENTIFIER %s\n", yytext); return TOKEN_IDENTIFIER; }
[0-9]+(\.[0-9]+)?	{ printf("NUMBER %s\n", yytext); return TOKEN_NUMBER; }
"+"	{ printf("PLUS\n"); return yytext[0]; }
"-"	{ printf("MINUS\n"); return yytext[0]; }
\/\/[^\n]*/\n	{ printf("COMMENT %s", yytext); }
\"([^"]|(\\\.))*\"	{ printf("STRING %s", yytext); }
[ \t\r]	{}
\n	{ yylineno++; }
.	{ printf("ERROR %s \n", yytext); }

%%

