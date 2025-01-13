# QuickScript

`QuickScript` is a high-level interpreted programming language designed for simplicity and clarity, with a focus on structured programming concepts. It is particularly suited for beginners and intermediate programmers who want to explore programming principles such as variable declarations, arithmetic operations, conditional logic, loops, and functions in an intuitive and expressive syntax.

## Features

- [Master Function](#master-function)
- [Show Function](#show-function)
- [Variable (Number, String, Boolean)](#variable-number-string-boolean)
- [Arithmetic Operations](#arithmetic-operations)
- [Conditional Statements](#conditional-statements)
- [Loop Constructs](#loop-constructs)
- [Slave Function](#slave-function)
- [Error Handling](#error-handling)

### Master Function

The Master Function `master()` is the entry point of every QuickScript program. It serves as the starting point where the program execution begins.

```
master() {
    // Your code goes here
}
```

### Show Function

The `show()` function in QuickScript is used to output messages or variable values to the console or an output file. It allows you to easily display information during program execution, making it a critical tool for debugging and user interaction.

```
show(expression);
```

### Variables

`Variables` in QuickScript are used to store and manipulate data. They are defined using a specific data type and can hold values assigned during or after declaration.

#### Supported Data Types:

- `number(integer, float)`
- `string`
- `boolean(true, false)`

```
number var1;
string var2;

number var3 = 10;
number var4 = 10.45;
string var5 = "Hello World";
```

### Arithmetic Operations

| Operator       | Symbol | Description                       | Example |
| -------------- | ------ | --------------------------------- | ------- |
| Addition       | +      | Adds two numbers                  | a + b   |
| Subtraction    | -      | Subtracts one number from another | a - b   |
| Multiplication | \*     | Multiplies two numbers            | a \* b  |
| Division       | /      | Divides one number by another     | a / b   |

```
number a = 10;
number b = 5;

number add = a + b;
show(add);

number sub = a - b;
show(sub);

number mul = a * b;
show(mul);

number div = a / b;
show(div);
```

### Conditional Statements

Boolean expressions in programming involve logical operations that evaluate to true or false. In the provided script, comparisons like `>`, `<`, `==` are used within `conditional structure`s to make decisions.

- if-else Block

```
if (c > b)
{
    show(c);
}
else
{
    show(b);
}

```

- if-elif-else Block

```
if (d > 16)
{
    show(d);
}
elif (d == 16)
{
    show(d);
}
else
{
    show(a);
}

```

### Loop Constructs

The `QuickScript` demonstrates the use of a `loop` construct to iterate over a range of values. Loops are a fundamental programming structure used to repeat a block of code multiple times based on specified conditions.

```
loop i from 1 to 3 => {
    show(i);
}

```

### Slave Function

In the `QuickScript`, the `slave` construct defines a nested function within the master function. This demonstrates modularity and encapsulation in the custom programming language. Here's a detailed exploration of the slave function, its usage, and its behavior.

```
slave calculate() {
    number p = 10;
    number q = 5;
    number calc = p + q;
    show(calc);
    return calc;
}

calculate();

```

### Error Handling

In `QuickScript`, the master function serves as the entry point for the script execution. It is equivalent to the main function in many programming languages. If the master function is missing, the script cannot execute as there is no defined starting point.

## Sample Input

```
master() {

    number a = 3.3;
    number b = 5.9;
    string s = "Hello, world!";

    show(a);
    show(s);

    number c = a + b;
    show(c);

    if (c > b)
    {
        show(c);
    }
    else
    {
        show(b);
    }

    number d = c * 2;

    if (d > 16)
    {
        show(d);
    }
    elif (d == 16)
    {
        show(d);
    }
    else
    {
        show(a);
    }
    number i = 0;
    loop i from 1 to 3 => {
        show(i);
    }
    number y = 10 + i;
    show(y);

    slave calculate() {
        number p = 10;
        number q = 5;
        number calc = p + q;
        show(calc);
        return calc;
    }

    calculate();
}

```

## Sample Output

```
=== Program Analysis Started ===

=== Entering Master Function ===
Show statement: a = 3.3
Show statement: s = "Hello, world!"
Show statement: c = 9.20
Show statement: c = 9.20
Show statement: b = 5.9
IF-ELSE block executed
Show statement: d = 18.40
Show statement: d = 18.40
ELIF block executed
Show statement: a = 3.3
IF-ELIF-ELSE block executed
Show statement: i = 0

=== Loop Starting ===
Iterator: i, Range: 1 to 3

--- Loop Iteration 1 ---
Iterator i = 1

--- Loop Iteration 2 ---
Iterator i = 2

--- Loop Iteration 3 ---
Iterator i = 3

=== Loop Completed ===
Show statement: y = 13.00
Show statement: calc = 15.00
Return value: 15.00
Function calculate declared
Function calculate called
=== Exiting Master Function ===

=== Variable Declaration Summary ===
Total variables found: 10

Variable #1:
  Name: a
  Type: number
  Value: 3.3

Variable #2:
  Name: b
  Type: number
  Value: 5.9

Variable #3:
  Name: s
  Type: string
  Value: "Hello, world!"

Variable #4:
  Name: c
  Type: number
  Value: 9.20

Variable #5:
  Name: d
  Type: number
  Value: 18.40

Variable #6:
  Name: i
  Type: number
  Value: 3

Variable #7:
  Name: y
  Type: number
  Value: 13.00

Variable #8:
  Name: p
  Type: number
  Value: 10

Variable #9:
  Name: q
  Type: number
  Value: 5

Variable #10:
  Name: calc
  Type: number
  Value: 15.00
```

## How to Download and Run the Parser from GitHub

This guide explains how to download the project files from a GitHub repository, compile the code, and execute the parser.

---

## Prerequisites

Ensure you have the following tools installed on your system:

- **Git** - To clone the repository.
- **GCC** - To compile the source code.
- **Bison** - For generating the parser.
- **Flex** - For generating the lexer.

---

## Steps to Download and Run

### 1. Clone the Repository

Run the following command in your terminal to clone the repository:

```bash
git clone <repository-url>

cd <repository-name>

```

### 2. Compile and Build the Parser

```
gcc -c symbol_table.c

bison -d script.y

flex script.l

gcc lex.yy.c script.tab.c symbol_table.o -o parser

./parser.exe input.txt output.txt
```

### 3. Direct Run

```
./run.bat

```
