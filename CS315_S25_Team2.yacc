%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int lineno;
void yyerror(const char *s);
int yylex(void);
%}

/* Define the types for semantic values */
%union {
    int ival;
    float fval;
    char* sval;
}

/* Token declarations */
%token START_SYMBOL END_SYMBOL
%token IF ELSE ELIF WHILE FOR FUNC RETURN CONTINUE BREAK
%token PRINT INPUT
%token INT FLOAT BOOL CHAR STRING
%token IDENTIFIER
%token CONST_INT CONST_FLOAT CONST_STRING
%token ASSIGNMENT_OP ADDITION SUBTRACTION MULTIPLICATION DIVISION
%token OR AND EQUALITY INEQUALITY
%token LESS_THAN GREATER_THAN LESS_THAN_OR_EQUAL GREATER_THAN_OR_EQUAL
%token NOT
%token LP RP LSQB RSQB COMMA SEMICOLON
%token START STOP
%token ASSIGN_PLUS ASSIGN_MINUS ASSIGN_MULTIPLY ASSIGN_DIVIDE MODULO POWER
%token TRUE FALSE CONST_CHAR
%token COMMENT_LINE COMMENT_BLOCK

/* Operator precedence and associativity */
%left OR 
%left AND 
%left EQUALITY INEQUALITY 
%left LESS_THAN GREATER_THAN LESS_THAN_OR_EQUAL GREATER_THAN_OR_EQUAL 
%left ADDITION SUBTRACTION 
%left MULTIPLICATION DIVISION MODULO 
%right POWER 
%right NOT 
%right ASSIGNMENT_OP ASSIGN_PLUS ASSIGN_MINUS ASSIGN_MULTIPLY ASSIGN_DIVIDE


%%
program:
      START_SYMBOL stmt_list END_SYMBOL
    ;

stmt_list:
     stmt
    | stmt stmt_list
    ;

stmt:
      if_stmt
	| casual_stmt;

/* If-elif-else statement definitions */
if_stmt:
      IF LP expr RP START stmt_list STOP
	| IF LP expr RP START stmt_list STOP elif_case
	| IF LP expr RP START stmt_list STOP else_case

elif_case:
      ELIF LP expr RP START stmt_list STOP
    | ELIF LP expr RP START stmt_list STOP elif_case
    | ELIF LP expr RP START stmt_list STOP else_case
    ;

else_case:
      ELSE START stmt_list STOP
    ;

casual_stmt:
	declaration_stmt SEMICOLON
	| init_stmt SEMICOLON
	| assign_stmt SEMICOLON
	| loop_stmt
	| jump_stmt SEMICOLON
	| comment
	| print_stmt SEMICOLON
	| function_declaration
	| function_call SEMICOLON
;

declaration_stmt:
      data_type identifier_list
    | data_type IDENTIFIER LSQB CONST_INT RSQB
    ;

identifier_list:
	IDENTIFIER
	| IDENTIFIER COMMA identifier_list
;

init_stmt:
	data_type identifier_list ASSIGNMENT_OP expr
	| data_type identifier_list ASSIGNMENT_OP INPUT LP CONST_STRING RP
	| data_type IDENTIFIER LSQB CONST_INT RSQB ASSIGNMENT_OP START array_arg_list STOP
;
array_arg_list: 
	expr COMMA array_arg_list
	| expr
;

	

assign_stmt:
            IDENTIFIER all_assign_ops expr
	| IDENTIFIER all_assign_ops assign_stmt
           | IDENTIFIER ASSIGNMENT_OP INPUT LP CONST_STRING RP
	| array_access all_assign_ops expr
	| array_access ASSIGNMENT_OP INPUT LP CONST_STRING RP
    ;
all_assign_ops:
	ASSIGNMENT_OP
	| ASSIGN_PLUS
	| ASSIGN_MINUS
	| ASSIGN_MULTIPLY
	| ASSIGN_DIVIDE
;
array_access:
	IDENTIFIER LSQB expr RSQB
;

expr:
      logic_expr
    ;

logic_expr:
	or_expr
;

or_expr:
	or_expr OR and_expr
	| and_expr
;

and_expr:
      and_expr AND equality_expr
    | equality_expr
    ;

equality_expr:
      equality_expr EQUALITY relation_expr
    | equality_expr INEQUALITY relation_expr
    | relation_expr
    ;

relation_expr:
      relation_expr LESS_THAN not_expr
    | relation_expr GREATER_THAN not_expr
    | relation_expr LESS_THAN_OR_EQUAL not_expr
    | relation_expr GREATER_THAN_OR_EQUAL not_expr
    | not_expr
    ;

not_expr:
      NOT not_expr
    | math_expr
    ;
math_expr:
	addition_expr
;

addition_expr:
      addition_expr ADDITION mult_expr
    | addition_expr SUBTRACTION mult_expr
	| addition_expr MODULO mult_expr
    | mult_expr
    ;

mult_expr:
      mult_expr MULTIPLICATION power_expr
    | mult_expr DIVISION power_expr
    | power_expr
    ;

power_expr:
	power_expr POWER unary_expr 
	| unary_expr
    ;

unary_expr:
	ADDITION unary_expr
	| SUBTRACTION unary_expr 
	| basic_expr
;

basic_expr:
	LP expr RP
	| IDENTIFIER
	| constant
	| function_call
	| array_access
;
loop_stmt:
	WHILE LP expr RP START stmt_list STOP
	| FOR LP init_stmt SEMICOLON expr SEMICOLON assign_stmt RP START stmt_list STOP
	|FOR LP assign_stmt SEMICOLON expr SEMICOLON assign_stmt RP START stmt_list STOP
	| FOR LP  SEMICOLON expr SEMICOLON assign_stmt RP START stmt_list STOP
	| FOR LP  SEMICOLON expr SEMICOLON  RP START stmt_list STOP
;
jump_stmt:
	RETURN expr
	| RETURN
	| CONTINUE
	| BREAK
;
print_stmt:
	PRINT LP list_to_printing RP 
;
list_to_printing:
	to_print
	| to_print COMMA list_to_printing
;
to_print:
	expr
;



function_declaration:
	FUNC IDENTIFIER LP RP START stmt_list STOP
	| FUNC IDENTIFIER LP param_list RP START stmt_list STOP
;
	
param_list:
param
| param COMMA param_list
;

param:
data_type IDENTIFIER
;	

function_call:
	IDENTIFIER LP RP
	| IDENTIFIER LP arg_list RP
;

arg_list:
	expr
	| expr COMMA arg_list
;

data_type:
	INT 
| FLOAT 
| BOOL 
| CHAR 
| STRING
;

constant:
	CONST_INT
	| CONST_FLOAT
	| TRUE
	| FALSE
	| CONST_CHAR
	| CONST_STRING

comment:
	COMMENT_LINE
	| COMMENT_BLOCK
;

%%
#include "lex.yy.c"

void yyerror(const char *s) {
    fprintf(stderr, "Syntax error on line %d!\n", lineno);
}
int main() {
    int returnValue =  yyparse();
    if (returnValue == 0) {
        printf("Input program is valid!\n");
    }
    return returnValue;
}
