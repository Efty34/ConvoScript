%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

SymbolTable *current_scope = NULL; 
SymbolTable *global_scope = NULL;

/*
  Extern declarations from the Flex-generated scanner:
*/
int yylex();
extern FILE *yyin;

/* Global variables and helper functions */
FILE *outputFile;
SymbolTable *symbolTable;

/* Track if a master function was successfully parsed */
int has_master = 0;

/* Count how many variables were declared */
int var_count = 0;

/* 
 * Print error messages. 
 * By default, we call exit(1) to stop after the first fatal parse error.
 */
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    exit(1);
}

/*
 * Helper: Perform arithmetic on two stringified numbers and return a new string.
 * We keep the result with 2 decimal places. 
 */
char* perform_arithmetic(const char* val1, const char* val2, char op) {
    double num1 = atof(val1);
    double num2 = atof(val2);
    double result = 0.0;
    char* result_str = (char*)malloc(50);

    switch(op) {
        case '+': result = num1 + num2; break;
        case '-': result = num1 - num2; break;
        case '*': result = num1 * num2; break;
        case '/': 
            if(num2 != 0) {
                result = num1 / num2;
            } else {
                fprintf(outputFile, "Error: Division by zero! Setting to 0.\n");
                result = 0.0;
            }
            break;
        default:
            /* Should never happen if the grammar is correct */
            break;
    }
    sprintf(result_str, "%.2f", result);
    return result_str;
}

/*
 * Helper: Evaluate a condition (>, <, >=, <=, ==, !=) between two numeric values.
 * Returns a newly allocated string "true" or "false".
 */
char* evaluate_condition(const char* val1, const char* val2, const char* op) {
    double num1 = atof(val1);
    double num2 = atof(val2);
    char* result = (char*)malloc(6); /* big enough for "true"/"false" + null */

    if (strcmp(op, ">") == 0) {
        strcpy(result, (num1 > num2) ? "true" : "false");
    } else if (strcmp(op, "<") == 0) {
        strcpy(result, (num1 < num2) ? "true" : "false");
    } else if (strcmp(op, ">=") == 0) {
        strcpy(result, (num1 >= num2) ? "true" : "false");
    } else if (strcmp(op, "<=") == 0) {
        strcpy(result, (num1 <= num2) ? "true" : "false");
    } else if (strcmp(op, "==") == 0) {
        strcpy(result, (num1 == num2) ? "true" : "false");
    } else if (strcmp(op, "!=") == 0) {
        strcpy(result, (num1 != num2) ? "true" : "false");
    } else {
        /* Unknown operator, default to false */
        strcpy(result, "false");
    }
    return result;
}

%}

/*
 * Bison Declarations
 */

/* Our union for semantic values */
%union {
    char *strval;
    int   intval;
}

/* Tokens */
%token LBRACE RBRACE LPAREN RPAREN SEMICOLON EQUALS
%token MASTER DATATYPE SHOW INPUT IDENTIFIER STRING NUMBER
%token PLUS MINUS MULTIPLY DIVIDE
%token GT LT GE LE EQ NE TRUE FALSE
%token IF ELSE ELIF
%token LOOP FROM TO ARROW


/* Precedence and associativity rules for arithmetic operators */
%left PLUS MINUS
%left MULTIPLY DIVIDE

/*
   Declare which nonterminals return <strval> from the union
   (so Bison knows how to store them).
*/
%type <strval> IDENTIFIER STRING NUMBER DATATYPE
%type <strval> variable_declaration show_function input_function
%type <strval> expr term factor
%type <strval> conditional_expr bool_expr
%type <strval> loop_statement
%type <strval> loop_block
%type <strval> loop_statements


%%
/* Top-level grammar */

program:
    {
        /* Initialize the symbol table, variables, etc. */
        global_scope = create_symbol_table();
        current_scope = global_scope;
        symbolTable = global_scope;
        has_master = 0;
        var_count = 0;
        fprintf(outputFile, "=== Program Analysis Started ===\n\n");
    }
    program_content
;

program_content:
    master_function
    /* If we didn't match master_function, try matching statements -> error. */
    | statements 
      {
        fprintf(outputFile, "\n=== ERROR: No Master Function Found ===\n");
        YYERROR; /* Triggers parse error and stops. */
      }
;

/*
 * The master_function is mandatory for a valid program. 
 * This rule enforces MASTER() { statements }.
 */
master_function:
    MASTER LPAREN RPAREN LBRACE 
      {
        fprintf(outputFile, "=== Entering Master Function ===\n");
      }
      statements
    RBRACE
    {
        has_master = 1;
        fprintf(outputFile, "=== Exiting Master Function ===\n\n");

        /* 
         * Print summary of declared variables 
         * after we've parsed all statements inside the master function.
         */
        fprintf(outputFile, "=== Variable Declaration Summary ===\n");
        fprintf(outputFile, "Total variables found: %d\n\n", var_count);

        for (int i = 0; i < symbolTable->size; i++) {
            fprintf(outputFile, "Variable #%d:\n", i + 1);
            fprintf(outputFile, "  Name: %s\n", symbolTable->symbols[i].name);
            fprintf(outputFile, "  Type: %s\n", symbolTable->symbols[i].type);
            fprintf(outputFile, "  Value: %s\n\n", symbolTable->symbols[i].value);
        }
    }
;

/* A sequence of statements */
statements:
    statements statement
    | statement
;

/* A single statement can be variable declaration, show, input, or if-block */
statement:
    variable_declaration
    | show_function
    | input_function
    | if_statement
    | loop_statement
;

/*
 * Variable Declaration
 * e.g. "number x = 5;" or "string y = "hello";" 
 * Also can assign a bool_expr: "number check = (expr > expr);"
 */
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

/*
 * Arithmetic Expressions
 */
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

/* A factor can be a NUMBER, STRING, IDENTIFIER, or (expr) */
factor:
    NUMBER      { $$ = $1; }
    | STRING    { $$ = $1; }
    | IDENTIFIER
      {
          Symbol *sym = get_symbol(symbolTable, $1);
          if (sym) {
              $$ = sym->value;
          } else {
              $$ = "0";
              fprintf(outputFile, "Error: Undefined variable %s. Using 0.\n", $1);
          }
      }
    | LPAREN expr RPAREN { $$ = $2; }
;

/*
 * Boolean Expressions:
 *   - direct conditional_expr
 *   - or parentheses around conditional_expr
 */
bool_expr:
    LPAREN conditional_expr RPAREN  { $$ = $2; }
    | conditional_expr              { $$ = $1; }
;

/* Conditionals: >, <, >=, <=, ==, != */
conditional_expr:
    expr GT expr   { $$ = evaluate_condition($1, $3, ">"); }
    | expr LT expr { $$ = evaluate_condition($1, $3, "<"); }
    | expr GE expr { $$ = evaluate_condition($1, $3, ">="); }
    | expr LE expr { $$ = evaluate_condition($1, $3, "<="); }
    | expr EQ expr { $$ = evaluate_condition($1, $3, "=="); }
    | expr NE expr { $$ = evaluate_condition($1, $3, "!="); }
;

/* if / elif / else statements */
if_statement:
    /* if(...) { statements } */
    IF LPAREN conditional_expr RPAREN LBRACE statements RBRACE
    {
        fprintf(outputFile, "IF block executed\n");
    }
    /* if(...) { statements } else { statements } */
    | IF LPAREN conditional_expr RPAREN LBRACE statements RBRACE ELSE LBRACE statements RBRACE
    {
        fprintf(outputFile, "IF-ELSE block executed\n");
    }
    /* if(...) { statements } elif_chains else { statements } */
    | IF LPAREN conditional_expr RPAREN LBRACE statements RBRACE elif_chains ELSE LBRACE statements RBRACE
    {
        fprintf(outputFile, "IF-ELIF-ELSE block executed\n");
    }
;

/* One or more ELIF blocks */
elif_chains:
    elif_chain
    | elif_chains elif_chain
;

/* A single ELIF (...) { statements } */
elif_chain:
    ELIF LPAREN conditional_expr RPAREN LBRACE statements RBRACE
    {
        fprintf(outputFile, "ELIF block executed\n");
    }
;

/* Modified loop statement with proper scope handling */
loop_statement:
    LOOP IDENTIFIER FROM expr TO expr ARROW loop_block
    {
        int start = atoi($4);
        int end = atoi($6);
        char iterator_name[128];
        strcpy(iterator_name, $2);
        
        SymbolTable *loop_scope = create_symbol_table();
        
        // Copy initial values to loop scope
        for (int i = 0; i < symbolTable->size; i++) {
            add_symbol(loop_scope, 
                      symbolTable->symbols[i].name,
                      symbolTable->symbols[i].type,
                      symbolTable->symbols[i].value);
        }
        
        fprintf(outputFile, "\n=== Loop Starting ===\n");
        fprintf(outputFile, "Iterator: %s, Range: %d to %d\n", iterator_name, start, end);
        
        for (int i = start; i <= end; i++) {
            fprintf(outputFile, "\n--- Loop Iteration %d ---\n", i);
            
            // Update iterator in loop scope
            char value[50];
            sprintf(value, "%d", i);
            update_symbol(loop_scope, iterator_name, value);
            fprintf(outputFile, "Iterator %s = %d\n", iterator_name, i);
            
            // Execute loop body in loop scope
            SymbolTable *temp = symbolTable;
            symbolTable = loop_scope;
            
            $8;  // Execute statements
            
            // Update parent scope with loop scope values
            for (int j = 0; j < loop_scope->size; j++) {
                Symbol *loop_sym = &loop_scope->symbols[j];
                update_symbol(temp, loop_sym->name, loop_sym->value);
            }
            
            symbolTable = temp;
        }
        
        // Ensure iterator's final value is in parent scope
        char final_value[50];
        sprintf(final_value, "%d", end);
        update_symbol(symbolTable, iterator_name, final_value);
        
        free_symbol_table(loop_scope);
        fprintf(outputFile, "\n=== Loop Completed ===\n");
    }
;




loop_block:
    LBRACE loop_statements RBRACE
    { $$ = $2; }
;

loop_statements:
    statements
    { $$ = strdup("loop_statements"); }  /* Just a placeholder return value */
;



/* show_function and input_function */
show_function:
    SHOW LPAREN IDENTIFIER RPAREN SEMICOLON
    {
        Symbol *sym = get_symbol(symbolTable, $3);
        if (sym) {
            fprintf(outputFile, "Show statement: %s = %s\n", sym->name, sym->value);
        } else {
            fprintf(outputFile, "Show statement: Undefined variable %s\n", $3);
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
            /*
             * If you want actual user input, you'd prompt and read here,
             * then store into sym->value. For example:
             *   char buffer[128];
             *   printf("Enter value for %s: ", sym->name);
             *   scanf("%127s", buffer);
             *   free(sym->value);
             *   sym->value = strdup(buffer);
             */
        } else {
            fprintf(outputFile, "Input for undefined variable %s\n", $3);
        }
        $$ = $3;
    }
;

%%

/*
 * Main function: parse command line, open files, run parser, close.
 */
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

    /* Redirect Flex to read from the specified input file */
    yyin = inputFile;

    /* Start the parse */
    yyparse();

    fclose(inputFile);
    fclose(outputFile);

    return 0;
}
