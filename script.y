%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

void yyerror(const char *s);
int yylex();
extern FILE *yyin;
FILE *outputFile;
SymbolTable *symbolTable;
int has_master = 0;
int var_count = 0;

char* perform_arithmetic(const char* val1, const char* val2, char op) {
    double num1 = atof(val1);
    double num2 = atof(val2);
    double result;
    char* result_str = malloc(50);
    
    switch(op) {
        case '+': result = num1 + num2; break;
        case '-': result = num1 - num2; break;
        case '*': result = num1 * num2; break;
        case '/': 
            if(num2 != 0) result = num1 / num2;
            else {
                fprintf(outputFile, "Error: Division by zero!\n");
                result = 0;
            }
            break;
    }
    sprintf(result_str, "%.2f", result);
    return result_str;
}

char* evaluate_condition(const char* val1, const char* val2, char* op) {
    double num1 = atof(val1);
    double num2 = atof(val2);
    char* result = malloc(6); // enough for "true" or "false"
    
    if (strcmp(op, ">") == 0) {
        strcpy(result, num1 > num2 ? "true" : "false");
    } else if (strcmp(op, "<") == 0) {
        strcpy(result, num1 < num2 ? "true" : "false");
    } else if (strcmp(op, ">=") == 0) {
        strcpy(result, num1 >= num2 ? "true" : "false");
    } else if (strcmp(op, "<=") == 0) {
        strcpy(result, num1 <= num2 ? "true" : "false");
    } else if (strcmp(op, "==") == 0) {
        strcpy(result, num1 == num2 ? "true" : "false");
    } else if (strcmp(op, "!=") == 0) {
        strcpy(result, num1 != num2 ? "true" : "false");
    }
    return result;
}


%}

%union {
    char *strval;
    int intval;
}

%token LBRACE RBRACE LPAREN RPAREN SEMICOLON EQUALS
%token MASTER DATATYPE SHOW INPUT IDENTIFIER STRING NUMBER
%token PLUS MINUS MULTIPLY DIVIDE
%token GT LT GE LE EQ NE TRUE FALSE
%token IF ELSE ELIF

%left PLUS MINUS
%left MULTIPLY DIVIDE

%type <strval> IDENTIFIER STRING NUMBER DATATYPE
%type <strval> variable_declaration show_function input_function
%type <strval> expr term factor
%type <strval> conditional_expr bool_expr

%%

program: 
    { 
        symbolTable = create_symbol_table(); 
        has_master = 0;
        fprintf(outputFile, "=== Program Analysis Started ===\n\n");
    }
    program_content
    ;

program_content:
    master_function
    | statements
    {
        fprintf(outputFile, "\n=== ERROR: No Master Function Found ===\n");
        YYERROR;
    }
    ;

master_function:
    MASTER LPAREN RPAREN LBRACE statements RBRACE
    {
        has_master = 1;
        fprintf(outputFile, "\n=== Variable Declaration Summary ===\n");
        fprintf(outputFile, "Total variables found: %d\n\n", var_count);
        for (int i = 0; i < symbolTable->size; i++) {
            fprintf(outputFile, "Variable #%d:\n", i + 1);
            fprintf(outputFile, "  Name: %s\n", symbolTable->symbols[i].name);
            fprintf(outputFile, "  Type: %s\n", symbolTable->symbols[i].type);
            fprintf(outputFile, "  Value: %s\n\n", symbolTable->symbols[i].value);
        }
    }
    ;

statements:
    statements statement
    | statement
    ;

statement:
    variable_declaration
    | show_function
    | input_function
    | if_statement
    ;

variable_declaration:
    DATATYPE IDENTIFIER EQUALS expr SEMICOLON
    {
        var_count++;
        add_symbol(symbolTable, $2, $1, $4);
    }
    | DATATYPE IDENTIFIER EQUALS bool_expr SEMICOLON
    {
        var_count++;
        add_symbol(symbolTable, $2, $1, $4);
    }
    ;

expr:
    term
    | expr PLUS term   { $$ = perform_arithmetic($1, $3, '+'); }
    | expr MINUS term  { $$ = perform_arithmetic($1, $3, '-'); }
    ;

term:
    factor
    | term MULTIPLY factor  { $$ = perform_arithmetic($1, $3, '*'); }
    | term DIVIDE factor    { $$ = perform_arithmetic($1, $3, '/'); }
    ;

factor:
    NUMBER { $$ = $1; }
    | STRING { $$ = $1; }
    | IDENTIFIER 
    {
        Symbol *sym = get_symbol(symbolTable, $1);
        if (sym) {
            $$ = sym->value;
        } else {
            $$ = "0";
            fprintf(outputFile, "Error: Undefined variable %s\n", $1);
        }
    }
    | LPAREN expr RPAREN { $$ = $2; }
    ;

bool_expr:
    LPAREN conditional_expr RPAREN { $$ = $2; }
    | conditional_expr             { $$ = $1; }
    ;

conditional_expr:
    expr GT expr   { $$ = evaluate_condition($1, $3, ">"); }
    | expr LT expr { $$ = evaluate_condition($1, $3, "<"); }
    | expr GE expr { $$ = evaluate_condition($1, $3, ">="); }
    | expr LE expr { $$ = evaluate_condition($1, $3, "<="); }
    | expr EQ expr { $$ = evaluate_condition($1, $3, "=="); }
    | expr NE expr { $$ = evaluate_condition($1, $3, "!="); }
    ;

if_statement:
    IF LPAREN conditional_expr RPAREN LBRACE statements RBRACE
    {
        fprintf(outputFile, "IF block executed\n");
    }
    | IF LPAREN conditional_expr RPAREN LBRACE statements RBRACE ELSE LBRACE statements RBRACE
    {
        fprintf(outputFile, "IF-ELSE block executed\n");
    }
    | IF LPAREN conditional_expr RPAREN LBRACE statements RBRACE elif_chains ELSE LBRACE statements RBRACE
    {
        fprintf(outputFile, "IF-ELIF-ELSE block executed\n");
    }
    ;

elif_chains:
    elif_chain
    | elif_chains elif_chain
    ;

elif_chain:
    ELIF LPAREN conditional_expr RPAREN LBRACE statements RBRACE
    {
        fprintf(outputFile, "ELIF block executed\n");
    }
    ;

show_function:
    SHOW LPAREN IDENTIFIER RPAREN SEMICOLON
    {
        Symbol *sym = get_symbol(symbolTable, $3);
        if (sym) {
            fprintf(outputFile, "Show statement: %s = %s\n", sym->name, sym->value);
        }
        $$ = $3;
    }
    ;

input_function:
    INPUT LPAREN IDENTIFIER RPAREN SEMICOLON
    {
        Symbol *sym = get_symbol(symbolTable, $3);
        if (sym) {
            fprintf(outputFile, "Input for %s (current: %s)\n", sym->name, sym->value);
        }
        $$ = $3;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    exit(1);
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <input_file> <output_file>\n", argv[0]);
        return 1;
    }

    FILE *inputFile = fopen(argv[1], "r");
    if (!inputFile) {
        perror("Error opening input file");
        return 1;
    }

    outputFile = fopen(argv[2], "w");
    if (!outputFile) {
        perror("Error opening output file");
        fclose(inputFile);
        return 1;
    }

    yyin = inputFile;
    yyparse();

    fclose(inputFile);
    fclose(outputFile);
    return 0;
}
