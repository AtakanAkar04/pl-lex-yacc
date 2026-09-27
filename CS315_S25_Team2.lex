%{
int lineno = 1;
%}

/* Declare Part */
initial         {letter}|\$|\_
letter          [a-zA-Z]
digit           [0-9]
final           {initial}|{digit}
identifier      {initial}({final})*

/* Types */
data_type       {type_int}|{type_float}|{type_bool}|{type_char}|{type_string}
type_int        int
type_string     string
type_bool       bool
type_char       char
type_float      float

/* Operations */
op_assign_plus          \+\=
op_assign_minus         \-\=
op_assign_multiply      \*\=
op_assign_divide        \/\=
op_or                   \|\|
op_and                  \&\&
op_equality             \=\=
op_inequality           \!\=
op_less_than            \<
op_greater_than         \>
op_less_than_or_equal   \<\=
op_greater_than_or_equal \>\=
op_addition             \+
op_subtraction          \-
op_multiplication       \*
op_division             \/
op_assignment           \=
op_modulo               \%
op_power                \^
op_not                  \!

/* Func operations */
func            func

/* Constants */
const_char      \'(.)?\' 
const_string    \"([^"\\]|\\.)*\"
const_int       {digit}+
const_float     {digit}*(\.)?{digit}+
const_bool      true|false
true            true
false           false

/* Comments */
comment_line    \/\/.*
comment_block   \/\*([^*]|\*+[^*\/])*\*+\/

/* Start-End */
start_symbol    [<]DaK
end_symbol      [#][>]

/* IO */
print           print
input           input

/* Symbols */
semicolon             ;
comma                 ,
left_parentheses      \(
right_parentheses     \)
left_square_bracket   \[
right_square_bracket  \]
start                 begin
stop                   end

/* Loops */
loop_stmt       {for}|{while}
for             for
while           while

/* If-Else */
if              if
elif            elif
else            else

/* Jump Statements */
jump_stmt       {break}|{continue}|{return}
continue        continue
break           break
return          return

%%
{for}                     { return FOR; }
{while}                   { return WHILE; }
{if}                      { return IF; }
{elif}                    { return ELIF; }
{else}                    { return ELSE; }
{start}                   { return START; }
{stop}                     { return STOP; }
{continue}                { return CONTINUE; }
{break}                   { return BREAK; }
{return}                  { return RETURN; }
{op_or}                   { return OR; }
{op_and}                  { return AND; }
{op_equality}             { return EQUALITY; }
{op_inequality}           { return INEQUALITY; }
{op_less_than}            { return LESS_THAN; }
{op_greater_than}         { return GREATER_THAN; }
{op_less_than_or_equal}   { return LESS_THAN_OR_EQUAL; }
{op_greater_than_or_equal} { return GREATER_THAN_OR_EQUAL; }
{op_addition}             { return ADDITION; }
{op_subtraction}          { return SUBTRACTION; }
{op_multiplication}       { return MULTIPLICATION; }
{op_division}             { return DIVISION; }
{op_assignment}           { return ASSIGNMENT_OP; }
{op_assign_plus}          { return ASSIGN_PLUS; }
{op_assign_minus}         { return ASSIGN_MINUS; }
{op_assign_multiply}      { return ASSIGN_MULTIPLY; }
{op_assign_divide}        { return ASSIGN_DIVIDE; }
{op_modulo}               { return MODULO; }
{op_power}                { return POWER; }
{op_not}                  { return NOT; }
{type_int}                { return INT; }
{type_float}              { return FLOAT; }
{type_bool}               { return BOOL; }
{type_char}               { return CHAR; }
{type_string}             { return STRING; }
{func}                    { return FUNC; }
{const_int}               { return CONST_INT; }
{const_float}             { return CONST_FLOAT; }
{true}                    { return TRUE; }
{false}                   { return FALSE; }
{const_char}              { return CONST_CHAR; }
{const_string}            { return CONST_STRING; }
{start_symbol}            { return START_SYMBOL; }
{end_symbol}              { return END_SYMBOL; }
{semicolon}               { return SEMICOLON; }
{comma}                   { return COMMA; }
{left_parentheses}        { return LP; }
{right_parentheses}       { return RP; }
{left_square_bracket}     { return LSQB; }
{right_square_bracket}    { return RSQB; }
{comment_line}            { return COMMENT_LINE; }
{comment_block}           { return COMMENT_BLOCK; }
{input}                   { return INPUT; }
{print}                   { return PRINT; }
{identifier}              { return IDENTIFIER; }
[\n]+                     { lineno++; }
[ \t]+                    { /* ignore whitespace */ }
.                         { return yytext[0]; }
%%

int yywrap() { return 1; }
