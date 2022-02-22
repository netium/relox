#pragma once

#ifndef CLOX_SCANNER_H
#define CLOX_SCANNER_H

typedef enum {
	TOKEN_LEFT_PAREN, TOKEN_RIGHT_PAREN, TOKEN_LEFT_BRACE, TOKEN_RIGHT_BRACE,
	TOKEN_COMMA, TOKEN_DOT, TOKEN_MINUS, TOKEN_PLUS,
	TOKEN_SEMICOLON, TOKEN_SLASH, TOKEN_STAR,
	TOKEN_BANG, 
	TOKEN_LESS, 
	TOKEN_ERROR, TOKEN_EOF
} TokenType;

typedef struct {
	TokenType type;
	const char* start;
	int length;
	int line;
} Token;

void initScanner(const char* source);
Token scanToken();

#endif