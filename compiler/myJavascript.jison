
/* Lexical grammar */

%lex
%%

\n+                     /* skip lines */
\s+                     /* skip spaces */

/* blocks */
"_"                     return 'BLOCKLIMITER'

/* condition */
"?"                     return 'IF'

/* print */
"print"                 return 'PRINT'

/* integer */
[0-9]+?\b               return 'NUMBER'

/* variable */
[a-zA-Z0-9]+?\b         return 'VARIABLE'

/* string */
L?\"(\\.|[^\\"])*\"     return 'STRING'

/* operators */
"=="                    return 'EQUAL'
"<"                     return 'LESS'
">"                     return 'MORE'
"<="                    return 'LESSEQ'
">="                    return 'MOREEQ'
"!="                    return 'DIFFERENT'

/* value assignation */
":"                     return 'ASSIGN'

/* end of file */
<<EOF>>                 return 'EOF'

/* anything else is invalid */
.                       return 'INVALID'

/lex


/* Program start */
%start program
%%

// program is a list of instructions
program
    : instructions EOF
        {
            // when we reach the end of the file, we get the compilation result and save it into a file
            var fs = require('fs');

            var file_name = process.argv.slice(2) + ".js";

            fs.writeFile(file_name, $1, function(err) {
                if (err) {
                    console.log(err);
                } else {
                    console.log("Success, saved in " + file_name + ".");
                }
            });

            return $1;
        }
    ;

// instructions are a list of instructions or one instruction
instructions
    : instructions instr
        { $$ = $1+$2; }     // concatenate result of each instruction
    | instr
        { $$ = $1; }
    ;

// instruction is a condition, a variable declaration or a print
instr
    : if_condition
        { $$ = $1 }
    | declare_variable
        { $$ = $1 }
    | print
        { $$ = $1 }
    ;

// variable declaration
declare_variable
    : 'VARIABLE' 'ASSIGN' value
        { $$ = "var "+ $1 +" = "+ $3 +";" }
    ;

// value is an integer or a string
value
    : 'NUMBER'
        { $$ = $1 }
    | 'STRING'
        { $$ = $1 }
    ;

// condition
if_condition
    : 'IF' operand operator operand block
        { $$ = "if ("+ $2 + $3 + $4 +") "+ $5 }
    ;

// operand is a variable or a value
operand
    : 'VARIABLE'
        { $$ = $1 }
    | value
        { $$ = $1 }
    ;

// operators
operator
    : 'EQUAL'     { $$ = $1 }
    | 'LESS'      { $$ = $1 }
    | 'MORE'      { $$ = $1 }
    | 'LESSEQ'    { $$ = $1 }
    | 'MOREEQ'    { $$ = $1 }
    | 'DIFFERENT' { $$ = $1 }
    ;

// block is a continuation of instructions delimited by block limiter
block
    : 'BLOCKLIMITER' instructions 'BLOCKLIMITER'
        { $$ = "{"+ $2 +"}" }
    ;

// printing
print
    : 'PRINT' value
        { $$ = "console.log("+ $2 +");" }
    | 'PRINT' 'VARIABLE'
        { $$ = "console.log("+ $2 +");" }
    ;