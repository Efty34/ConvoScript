#include "symbol_table.h"

SymbolTable* create_symbol_table() {
    SymbolTable *table = malloc(sizeof(SymbolTable));
    table->capacity = 10;
    table->size = 0;
    table->symbols = malloc(sizeof(Symbol) * table->capacity);
    return table;
}

void add_symbol(SymbolTable *table, const char *name, const char *type, const char *value) {
    if (table->size >= table->capacity) {
        table->capacity *= 2;
        table->symbols = realloc(table->symbols, sizeof(Symbol) * table->capacity);
    }
    
    Symbol *symbol = &table->symbols[table->size++];
    symbol->name = strdup(name);
    symbol->type = strdup(type);
    symbol->value = strdup(value);
}

Symbol* get_symbol(SymbolTable *table, const char *name) {
    for (int i = 0; i < table->size; i++) {
        if (strcmp(table->symbols[i].name, name) == 0) {
            return &table->symbols[i];
        }
    }
    return NULL;
}

void free_symbol_table(SymbolTable *table) {
    for (int i = 0; i < table->size; i++) {
        free(table->symbols[i].name);
        free(table->symbols[i].type);
        free(table->symbols[i].value);
    }
    free(table->symbols);
    free(table);
}
