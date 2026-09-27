# DaK#

A small imperative programming language, with a lexer and parser written in **Lex** and **Yacc**.

DaK# has C-style operators, explicit types, and `begin` / `end` blocks. Every program sits between a `<DaK` start marker and a `#>` end marker. The parser reads a DaK# program from standard input and reports whether it is syntactically valid. If it is not, it prints the line number of the first syntax error.

> **Note:** This is a basic implementation that covers only the lexer and the parser. It tells you whether a program is syntactically valid, but it doesn't run programs, build a syntax tree, or check types. The [type rules](#type-rules) below are part of the language design, not something the parser enforces.

```text
<DaK
func max(int a, int b) begin
    if (a >= b) begin
        return a;
    end else begin
        return b;
    end
end

int nums[3] = begin 4, 9, 2 end;
int best = nums[0];

for (int i = 1; i < 3; i += 1) begin
    best = max(best, nums[i]);
end

print("The largest number is ", best);
#>
```

```console
$ ./parser < program.txt
Input program is valid!
```

---

## Contents

- [Building and running](#building-and-running)
- [Language tour](#language-tour)
- [Operator precedence](#operator-precedence)
- [Type rules](#type-rules)
- [Example programs](#example-programs)
- [Project layout](#project-layout)
- [Team](#team)

## Building and running

You need `lex`/`flex`, `yacc`/`bison` and a C compiler. On macOS these come with the Xcode Command Line Tools. On Debian/Ubuntu, run `sudo apt install flex bison build-essential`.

```sh
make                                  # generates lex.yy.c and y.tab.c, then builds ./parser
./parser < CS315_S25_Team2_1.txt     # a valid program
./parser < CS315_S25_Team2_1_error.txt   # a program with a syntax error
make clean                            # removes the generated files
```

| Result | Output | Exit code |
| --- | --- | --- |
| Valid program | `Input program is valid!` | `0` |
| Syntax error | `Syntax error on line N!` | non-zero |

The build has three steps: `lex` turns the token definitions into `lex.yy.c`, `yacc` turns the grammar into `y.tab.c` (which `#include`s the lexer), and `gcc` compiles the result.

## Language tour

### Program structure

A program starts with `<DaK`, ends with `#>`, and contains one or more statements. Blocks use `begin` and `end` instead of braces. Simple statements end with `;`. Block statements (`if`, loops, function declarations) do not.

### Types and variables

There are five types: `int`, `float`, `bool`, `char` and `string`.

```text
int count;                            // declaration
int x, y, z;                          // several at once
float ratio = 0.75;                   // declaration with initialization
string name = input("Your name: ");   // initialize from user input
int arr[3];                           // fixed-size array
float v[3] = begin 1.5, -2, .25 end;  // array literal
```

Identifiers start with a letter, `$` or `_`, followed by letters, digits, `$` or `_`.

### Literals

| Kind | Examples |
| --- | --- |
| `int` | `0`, `42` |
| `float` | `3.14`, `.5` |
| `bool` | `true`, `false` |
| `char` | `'a'` |
| `string` | `"hello"`, `"tab\there"` |

### Assignment

```text
x = 5;
x += 2;   x -= 1;   x *= 3;   x /= 2;
a = b = c = 0;                        // chained assignment
arr[i + 1] = x * 2;
arr[0] = input("First value: ");
```

### Control flow

```text
if (score >= 90) begin
    print("A");
end elif (score >= 80) begin
    print("B");
end else begin
    print("C");
end

while (n > 0) begin
    n -= 1;
end

for (int i = 0; i < 10; i += 1) begin ... end   // declaration as initializer
for (i = 0; i < 10; i += 1) begin ... end       // assignment as initializer
for (; i < 10; i += 1) begin ... end            // no initializer
for (; running; ) begin ... end                 // condition only
```

Inside a loop you can use `break;` and `continue;`. Inside a function you can use `return;` or `return expr;`.

### Functions

Functions are declared with `func`. Parameters are typed.

```text
func area(float w, float h) begin
    return w * h;
end

float a = area(3, 4.5);
```

### Input and output

- `print(e1, e2, ...)` prints one or more expressions.
- `input("prompt")` reads a value from the user. It can appear on the right-hand side of an initialization or an assignment.

### Comments

```text
// line comment
/* block
   comment */
```

The grammar treats comments as statements, so a comment can go anywhere a statement can.

## Operator precedence

The rows go from highest to lowest precedence. The grammar encodes this with one nonterminal per level (`or_expr`, `and_expr`, `equality_expr`, and so on down to `basic_expr`).

| Level | Operators | Associativity |
| --- | --- | --- |
| Primary | `( )`, identifiers, literals, function calls, `a[i]` | n/a |
| Unary | `+x`, `-x` | right |
| Power | `^` | left |
| Multiplicative | `*`, `/` | left |
| Additive | `+`, `-`, `%` | left |
| Logical NOT | `!` | right |
| Relational | `<`, `>`, `<=`, `>=` | left |
| Equality | `==`, `!=` | left |
| Logical AND | `&&` | left |
| Logical OR | `\|\|` | left |
| Assignment | `=`, `+=`, `-=`, `*=`, `/=` | right (statement level) |

## Type rules

The parser only checks syntax. The language design also defines the type-checking and implicit-conversion rules below. They are documented in the [project report](CS315_S25_Team2_Report.pdf).

- **Arithmetic**: if any operand is a `float`, the result is a `float`. Otherwise every operand is converted to an `int`.
- **Comparisons**: operands are compared as `float`s, and the result is a `bool`.
- **Logic** (`&&`, `||`, `!`): operands are converted to `bool`.
- **Array indices**: an index is converted to an `int`. A negative index counts from the end of the array.
- **`print`**: every argument is converted to a `string`.
- **Array literals**: every element is converted to the array's declared type.

Conversions:

| From → To | Rule |
| --- | --- |
| number → `bool` | `0` is `false`. Any other value is `true`. |
| `string` → `bool` | `""` is `false`. Any non-empty string is `true`. |
| `bool` → `int`/`float` | `false` becomes `0`, `true` becomes `1`. |
| `string` → `int`/`float` | `""` becomes `0`. Any non-empty string becomes `1`. |
| `float` → `int` | The fractional part is dropped (`arr[0.5]` is `arr[0]`). |
| anything → `string` | The value's text form (`false` becomes `"false"`, `5.4` becomes `"5.4"`). |

## Example programs

Each example has a valid version and a version with one deliberate syntax error.

| # | What it does | Error in the `_error` version |
| --- | --- | --- |
| 1 | Reads 10 numbers and counts how many are not divisible by a user-given non-zero number | Missing `;` after an array declaration |
| 2 | Fills an array from input, then computes `2 ^ max` | Missing `)` in an `input(...)` call |
| 3 | Classifies input numbers as odd or even | String prompt without quotes |
| 4 | Multiplies three non-zero inputs, restarting on zero (`continue` / `break`) | Missing `<DaK` / `#>` program markers |
| 5 | Nested loops over two float arrays, calling a two-parameter function | Missing `,` between function arguments |

## Project layout

```text
.
├── CS315_S25_Team2.lex          # lexer: token definitions
├── CS315_S25_Team2.yacc         # parser: grammar, precedence, main()
├── Makefile                     # builds ./parser
├── CS315_S25_Team2_{1..5}.txt       # valid example programs
├── CS315_S25_Team2_{1..5}_error.txt # the same programs with one syntax error each
└── CS315_S25_Team2_Report.pdf   # full language report: BNF, token list, design criteria, type rules
```

## Team

- Atakan Akar
- Hüseyin Deniz Kurtulan
- Kerem Varnalı

---

Made as a team project (Team 2) for **CS 315: Programming Languages**, Spring 2025.
