@echo off

rem Compile the symbol_table.c file
gcc -c symbol_table.c

rem Generate parser code from script.y using Bison
bison -d script.y

rem Generate lexer code from script.l using Flex
flex script.l

rem Compile the generated code and link everything
gcc lex.yy.c script.tab.c symbol_table.o -o parser

rem Run the parser with input and output files
parser.exe input.txt output.txt
