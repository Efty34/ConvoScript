#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// Symbol structure
typedef struct {
    char *name;
    char *type;
    char *value;
} Symbol;

// Symbol table structure
typedef struct {
    Symbol *symbols;
    int size;
    int capacity;
} SymbolTable;

// Function declarations
SymbolTable* create_symbol_table();
void add_symbol(SymbolTable *table, const char *name, const char *type, const char *value);
Symbol* get_symbol(SymbolTable *table, const char *name);
void update_symbol(SymbolTable *table, const char *name, const char *value); // Add this declaration
void remove_symbol(SymbolTable *table, const char *name);                   // Add this declaration
void free_symbol_table(SymbolTable *table);

#endif
