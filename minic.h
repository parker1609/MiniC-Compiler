#ifndef __UCODE_HEADER
#define __UCODE_HEADER

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LABEL_SIZE           8
#define SYMTAB_ARRAY_SIZE    512

typedef struct tokenType {
    int tokenNumber;
    char *tokenValue;
} Token;

typedef struct nodeType {
    Token token;
    enum {terminal, nonterm} noderep;
    struct nodeType *son;
    struct nodeType *brother;
} Node;

enum nodeNumber {
    ACTUAL_PARAM,   ADD,            ADD_ASSIGN,     ARRAY_VAR,      ASSIGN_OP,
    CALL,           COMPOUND_ST,    CONST_NODE,     DCL,            DCL_ITEM,
    DCL_LIST,       DCL_SPEC,       DIV,            DIV_ASSIGN,     EQ,
    ERROR_NODE,     EXP_ST,         FORMAL_PARA,    FUNC_DEF,       FUNC_HEAD,
    GE,             GT,             IDENT,          IF_ELSE_ST,     IF_ST,
    INDEX,          INT_NODE,       LE,             LOGICAL_AND,    LOGICAL_NOT,
    LOGICAL_OR,     LT,             MOD,            MOD_ASSIGN,     MUL,
    MUL_ASSIGN,     NE,             NUMBER,         PARAM_DCL,      POST_DEC,
    POST_INC,       PRE_DEC,        PRE_INC,        PROGRAM,        RETURN_ST,
    SIMPLE_VAR,     STAT_LIST,      SUB,            SUB_ASSIGN,     UNARY_MINUS,
    VOID_NODE,      WHILE_ST,
};

typedef enum {
    SPEC_NONE, SPEC_VOID, SPEC_INT
} Specifier;

typedef enum {
    QUAL_NONE, QUAL_FUNC, QUAL_PARA, QUAL_CONST, QUAL_VAR
} Qualifier;

typedef struct _SymbolRow {
    char *id;
    Specifier spec;
    Qualifier qual;
    int offset;
    int width;
    int base;
    int init;
    struct _SymbolTable *table;
} SymbolRow;

typedef struct _SymbolTable
{
    char *name;
    int count;
    int offset;
    int base;
    SymbolRow rows[SYMTAB_ARRAY_SIZE];
} SymbolTable;


void codeGen(Node *ptr, FILE *ucoFile);

#endif
