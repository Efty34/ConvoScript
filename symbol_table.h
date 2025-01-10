// symbol_table.h
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
    int scope_level;  // Add scope level tracking
} Symbol;

// Symbol table structure
typedef struct SymbolTable {
    Symbol *symbols;
    int size;
    int capacity;
    int current_scope_level;      // Track current scope level
    struct SymbolTable *parent;   // Link to parent scope
} SymbolTable;

// Function declarations
SymbolTable* create_symbol_table();
SymbolTable* create_symbol_table_with_parent(SymbolTable *parent);
void add_symbol(SymbolTable *table, const char *name, const char *type, const char *value);
Symbol* get_symbol(SymbolTable *table, const char *name);
Symbol* get_symbol_current_scope(SymbolTable *table, const char *name);
void update_symbol(SymbolTable *table, const char *name, const char *value);
void remove_symbol(SymbolTable *table, const char *name);
void copy_symbols_to_scope(SymbolTable *source, SymbolTable *dest);
void free_symbol_table(SymbolTable *table);
void enter_scope(SymbolTable *table);
void exit_scope(SymbolTable *table);
void copy_loop_values(SymbolTable *loop_scope, SymbolTable *parent_scope);

#endif