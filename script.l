%{
#include "script.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%%

master          { return MASTER; }
number|string   { yylval.strval = strdup(yytext); return DATATYPE; }
show            { return SHOW; }
input           { return INPUT; }
"true"          { yylval.strval = strdup(yytext); return TRUE; }
"false"         { yylval.strval = strdup(yytext); return FALSE; }
"if"            { return IF; }
"else"          { return ELSE; }
"elif"          { return ELIF; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.strval = strdup(yytext); return IDENTIFIER; }
[0-9]+\.[0-9]+|[0-9]+   { yylval.strval = strdup(yytext); return NUMBER; }
\"[^\"]*\"      { yylval.strval = strdup(yytext); return STRING; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULTIPLY; }
"/"             { return DIVIDE; }
">"             { return GT; }
"<"             { return LT; }
">="            { return GE; }
"<="            { return LE; }
"=="            { return EQ; }
"!="            { return NE; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
"("             { return LPAREN; }
")"             { return RPAREN; }
";"             { return SEMICOLON; }
"="             { return EQUALS; }
[ \t\n]+        { /* Ignore whitespace */ }
.               { printf("Unrecognized character: %s\n", yytext); }
%%

int yywrap() {
    return 1;
}