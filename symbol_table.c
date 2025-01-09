#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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

void update_symbol(SymbolTable *table, const char *name, const char *value) {
    Symbol *symbol = get_symbol(table, name);
    if (symbol) {
        free(symbol->value);
        symbol->value = strdup(value);
    } else {
        fprintf(stderr, "Error: Symbol '%s' not found for update.\n", name);
    }
}

void remove_symbol(SymbolTable *table, const char *name) {
    int index = -1;

    for (int i = 0; i < table->size; i++) {
        if (strcmp(table->symbols[i].name, name) == 0) {
            index = i;
            break;
        }
    }

    if (index == -1) {
        fprintf(stderr, "Error: Symbol '%s' not found for removal.\n", name);
        return;
    }

    free(table->symbols[index].name);
    free(table->symbols[index].type);
    free(table->symbols[index].value);

    for (int i = index; i < table->size - 1; i++) {
        table->symbols[i] = table->symbols[i + 1];
    }

    table->size--;
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

void print_symbol_table(SymbolTable *table) {
    printf("=== Symbol Table ===\n");
    for (int i = 0; i < table->size; i++) {
        printf("Name: %s, Type: %s, Value: %s\n", 
               table->symbols[i].name, 
               table->symbols[i].type, 
               table->symbols[i].value);
    }
    printf("====================\n");
}
