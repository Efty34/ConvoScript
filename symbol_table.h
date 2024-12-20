#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <string.h>
#include <stdlib.h>

typedef struct {
    char *name;
    char *type;
    char *value;
} Symbol;

typedef struct {
    Symbol *symbols;
    int size;
    int capacity;
} SymbolTable;

SymbolTable* create_symbol_table();
void add_symbol(SymbolTable *table, const char *name, const char *type, const char *value);
Symbol* get_symbol(SymbolTable *table, const char *name);
void free_symbol_table(SymbolTable *table);

#endif
