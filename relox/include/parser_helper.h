#ifndef _PARSER_HELPER_H_
#define _PARSER_HELPER_H_

#include "common.h"
#include "memory.h"

#include "compiler.h"

// #include "scanner.h"

#ifdef DEBUG_PRINT_CODE
#include "debug.h"
#endif

/* Type definitions */

typedef struct {
	Token current;
	Token previous;
	bool hadError;
	bool panicMode;
} Parser;

typedef enum {
	PREC_NONE,
	PREC_ASSIGNMENT,
	PREC_OR,
	PREC_AND,
	PREC_EQUALITY,
	PREC_COMPARISON,
	PREC_TERM,
	PREC_FACTOR,
	PREC_UNARY,
	PREC_CALL,
	PREC_PRIMARY
} Precedence;

typedef void (*ParseFn)(bool canAssign);

typedef struct {
	Token name;
	int depth;
	bool isCaptured;
} Local;

typedef struct {
	uint8_t index;
	bool isLocal;
} Upvalue;

typedef enum {
	TYPE_FUNCTION,
	TYPE_INITIALIZER,
	TYPE_METHOD,
	TYPE_SCRIPT
} FunctionType;

struct st_compiler;

typedef struct st_compiler {
	struct st_compiler * enclosing;
	ObjFunction* function;
	FunctionType type;

	Local locals[UINT8_COUNT];
	int localCount;
	Upvalue upvalues[UINT8_COUNT];
	int scopeDepth;
} Compiler;

typedef struct ClassCompiler {
	struct ClassCompiler* enclosing;
	bool hasSuperclass;
} ClassCompiler;

typedef struct {
	ParseFn prefix;
	ParseFn infix;
	Precedence precedence;
} ParseRule;


extern int yylineno;

void yyerror(const char *s, ...);

/* Implementation functions */

void parsePrecedence(Precedence precedence);
uint8_t identifierConstant(Token* name);
void expression();
void statement();
void declaration();
// ParseRule* getRule(TokenType type);
void and_(bool canAssign);
uint8_t argumentList();
int resolveUpvalue(Compiler* compiler, Token* name);
int resolveLocal(Compiler* compiler, Token* name);

Chunk* currentChunk();
void errorAt(Token* token, const char* message);
void error(const char* message);
void errorAtCurrent(const char* message);
static void advance();
void consume(TokenType type, const char* message);
bool check(TokenType type);
bool match(TokenType type);

void initCompiler(Compiler* compiler, FunctionType type);

void emitByte(uint8_t byte);
void emitBytes(uint8_t byte1, uint8_t byte2);
void emitConstant(Value value);
uint8_t makeConstant(Value value);
void emitReturn();
void emitLoop(int loopStart);
int emitJump(uint8_t instruction);
void patchJump(int offset);

ObjFunction *endCompiler();
void beginScope();
void endScope();
void expression();
ParseRule* getRule(TokenType type);
void parsePrecedence(Precedence precedence);
void call(bool canAssign);
void dot(bool canAssign);
void or_(bool canAssign);
void namedVariable(Token name, bool canAssign);
void variable(bool canAssign);
Token syntheticToken(const char* text);
void super_(bool canAssign);
void this_(bool canAssign);

void parsePrecedence(Precedence precedence);
uint8_t identifierConstant(Token* name);
bool identifiersEqual(Token* a, Token* b);
int resolveLocal(Compiler* compiler, Token* name);
int addUpvalue(Compiler* compiler, uint8_t index, bool isLocal);
int resolveUpvalue(Compiler* compiler, Token* name);
void addLocal(Token name);
void declareVariable();
uint8_t parseVariable(const char* errorMessage);
void markInitialized();
void defineVariable(uint8_t global);
uint8_t argumentList();
void and_(bool canAssign);
ParseRule* getRule(TokenType type);
void expression();
void block();
void function(FunctionType type);
void method();
void classDeclaration();
void funDeclaration();
void varDeclaration();
void expressionStatement();
void forStatement();
void ifStatement();
void synchronize();
void declaration();
void statement();
ObjFunction *compile(const char* source);
void markCompilerRoots();

int yylex (void);

#endif