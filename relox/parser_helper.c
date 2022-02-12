#include <stdarg.h>
#include <stdio.h>
#include "parser_helper.h"

void yyerror(const char *s, ...) {

    va_list ap;
    va_start(ap, s);

    fprintf(stderr, "%d: error: ", yylineno);
    vfprintf(stderr, s, ap);
    fprintf(stderr, "\n");
}