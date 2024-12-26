%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

letter  [a-z]
digit   [0-9]
number  0|[1-9]{digit}*|-[1-9]{digit}*
id      {letter}({letter}|{digit}|-)*

%%
"print-num"     {return(PNUM);}
"print-bool"    {return(PBOOL);}
"#f"            { yylval.bval = 0; return(BOOL);}
"#t"            { yylval.bval = 1; return(BOOL);}
"+"             {return(ADD);}
"-"             {return(SUB);}
"*"             {return(MUL);}
"/"             {return(DIV);}
"mod"           {return(MOD);}
">"             {return(GREATER);}
"<"             {return(SMALLER);}
"="             {return(EQUAL);}
"and"           {return(AND);}
"or"            {return(OR);}
"not"           {return(NOT);}
"define"        {return(DEF);}
"fun"           {return(FUN);}
"if"            {return(IF);}
"("             {return(LB);}
")"             {return(RB);}
{id}            { yylval.sval = strdup(yytext); return(ID);}
{number}        { yylval.ival = atoi(yytext) ; return(NUM);}
[ \t\n\r]       {}
.               {}
%%