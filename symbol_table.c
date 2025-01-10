// symbol_table.c
#include "symbol_table.h"

SymbolTable* create_symbol_table() {
    SymbolTable *table = malloc(sizeof(SymbolTable));
    table->capacity = 10;
    table->size = 0;
    table->symbols = malloc(sizeof(Symbol) * table->capacity);
    table->current_scope_level = 0;
    table->parent = NULL;
    return table;
}

SymbolTable* create_symbol_table_with_parent(SymbolTable *parent) {
    SymbolTable *table = create_symbol_table();
    table->parent = parent;
    table->current_scope_level = parent ? parent->current_scope_level + 1 : 0;
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
    symbol->scope_level = table->current_scope_level;
}

Symbol* get_symbol(SymbolTable *table, const char *name) {
    // First search in current scope
    for (int i = 0; i < table->size; i++) {
        if (strcmp(table->symbols[i].name, name) == 0) {
            return &table->symbols[i];
        }
    }
    
    // If not found and we have a parent scope, search there
    if (table->parent) {
        return get_symbol(table->parent, name);
    }
    
    return NULL;
}

Symbol* get_symbol_current_scope(SymbolTable *table, const char *name) {
    for (int i = 0; i < table->size; i++) {
        if (strcmp(table->symbols[i].name, name) == 0 && 
            table->symbols[i].scope_level == table->current_scope_level) {
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

void copy_symbols_to_scope(SymbolTable *source, SymbolTable *dest) {
    for (int i = 0; i < source->size; i++) {
        Symbol *sym = &source->symbols[i];
        add_symbol(dest, sym->name, sym->type, sym->value);
    }
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

void enter_scope(SymbolTable *table) {
    table->current_scope_level++;
}

void exit_scope(SymbolTable *table) {
    // Remove all symbols from the current scope
    int i = 0;
    while (i < table->size) {
        if (table->symbols[i].scope_level == table->current_scope_level) {
            remove_symbol(table, table->symbols[i].name);
        } else {
            i++;
        }
    }
    table->current_scope_level--;
}

void print_symbol_table_values(SymbolTable *table, FILE *output) {
    for (int i = 0; i < table->size; i++) {
        fprintf(output, "  %s = %s\n", 
                table->symbols[i].name,
                table->symbols[i].value);
    }
}

void copy_loop_values(SymbolTable *loop_scope, SymbolTable *parent_scope) {
    for (int i = 0; i < loop_scope->size; i++) {
        Symbol *loop_sym = &loop_scope->symbols[i];
        Symbol *parent_sym = get_symbol(parent_scope, loop_sym->name);
        if (parent_sym) {
            update_symbol(parent_scope, loop_sym->name, loop_sym->value);
        }
    }
}

